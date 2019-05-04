module Graphql.QuerySelectionGenerator exposing (..)

import Debug
import Dict exposing (Dict)
import Graphql.Generator.Context exposing (Context)
import Graphql.Generator.Decoder as Decoder
import Graphql.Generator.Group exposing (IntrospectionData)
import Graphql.Generator.ModuleName as ModuleName
import Graphql.Parser.CamelCaseName as CamelCaseName
import Graphql.Parser.ClassCaseName as ClassCaseName
import Graphql.Parser.Type as Type exposing (IsNullable(..), DefinableType(..), TypeReference(..), TypeDefinition(..), ReferrableType(..))
import ModuleName exposing (ModuleName(..))
import Graphql.Parser.Scalar as Scalar

import Set exposing (Set)
import Graphql.QueryParser exposing (..)

--utility from Result extra


combine =
    List.foldr (Result.map2 (::)) (Ok [])



--
type alias ElmRecordField =  { name : String, type_ : String }

type alias RecordContext =
    Dict String (List ElmRecordField)

type alias TranslationResult = 
    Result String 
        { imports : Set String
        , body : String
        , elmRecordField : ElmRecordField
        , recordContext : RecordContext 
        } 

argumentsToString : List Argument -> String
argumentsToString arguments =
    arguments
        |> List.map (\argument ->
            argument.name ++ " = " ++
            case argument.value of 
                Variable name -> "UNIMPLEMENTED"
                IntValue int -> String.fromInt int
                FloatValue float -> String.fromFloat float
                StringValue str -> str
                BooleanValue b -> if b then "True" else "False"
                NullValue  -> "UNIMPLEMENTED"
                EnumValue name -> "UNIMPLEMENTED"
                ListValue values ->  "UNIMPLEMENTED"
                ObjectValue objectValues ->  "UNIMPLEMENTED"
        )
        |> String.join ","

moduleName context typeDef =
    ModuleName.generate context typeDef

nameToTypeDef introspectionData =
    introspectionData.typeDefinitions
        |> List.map
            (\((TypeDefinition className _ _) as typeDef) ->
                ( ClassCaseName.raw className, typeDef )
            )
        |> Dict.fromList

findTypeDef introspectionData rootName =
    Dict.get rootName (nameToTypeDef introspectionData)

typeRefToString (TypeReference referrableType nullable) =
    let
        typeName = case referrableType of
            ObjectRef str -> 
                str
            Scalar scalar -> 
                Scalar.toString scalar
            List typeRef ->
                "List (" ++ typeRefToString typeRef ++ ")"
            _ ->
                "foo0"
    in
        case nullable of
            Nullable -> "Maybe (" ++ typeName ++ ")"
            NonNullable -> typeName


typeRefToType (TypeReference referrableType nullable) =
        case referrableType of
            ObjectRef str -> 
                str
            Scalar scalar -> 
                Scalar.toString scalar
            List typeRef ->
                typeRefToType typeRef
            _ ->
                "foo0"

typeDefinitionToString (TypeDefinition classCaseName definableType maybeDescription) =
    ClassCaseName.raw classCaseName

-- referrable modifies a DEFINED type, by making it list/optional
-- a definedtype you SELECT against

translateField : Context -> IntrospectionData -> RecordContext -> String -> FieldType -> TypeDefinition -> TranslationResult
translateField context introspectionData recordContext modulePath fieldType typeDefinition =
    let            
        fullyQualifiedFieldSelector =
            modulePath ++ "." ++ fieldType.name ++
                if List.isEmpty fieldType.arguments then
                    ""
                else
                    "{" ++ (argumentsToString fieldType.arguments) ++ "}"

        typeName = typeDefinitionToString typeDefinition
        -- typeName = typeRefToString typeRef

        -- maybeSubFieldTypeDef =
        --     findTypeDef introspectionData (typeRefToType typeRef)
    in
    case fieldType.selectionSet of
        -- ( Nothing, _ ) ->
        --     Err ("Can't resolve " ++ fieldType.name ++ " of type " ++ typeName)

        Nothing ->
            --scalar case
            Ok
                { imports = Set.singleton modulePath -- for now, scalars won't contribute any new imports, but could later
                , body = "|> with " ++ fullyQualifiedFieldSelector
                , elmRecordField =
                    { name = fieldType.name
                    , type_ = typeName
                    }
                , recordContext = recordContext
                }

        Just selectionSet__ ->
            translateSelectionSet context introspectionData recordContext typeDefinition selectionSet__
                |> Result.map
                    (\result ->
                        { imports =
                            result.imports
                                |> Set.insert modulePath
                        , body = "|> with (" ++ fullyQualifiedFieldSelector ++ " (\n" ++ result.body ++ "\n))"
                        , elmRecordField = 
                            { name = fieldType.name
                            , type_ = result.elmRecordField.type_ 
                            }
                        , recordContext = result.recordContext
                        }
                    )

translateSelectionSet : Context -> IntrospectionData -> RecordContext -> TypeDefinition ->  SelectionSet -> TranslationResult
translateSelectionSet context introspectionData recordContext ((TypeDefinition classCaseName definableType maybeDescription) as parentTypeDef) selectionSet =
    let
        targetRecordName =
            ClassCaseName.raw classCaseName ++ "Record"

        modulePath =
            moduleName context parentTypeDef
                |> String.join "."
    in
    selectionSet
        |> List.map (\(Field fieldType) -> 
            case definableType of
                ObjectType fields ->
                    fields
                        |> List.map (\field_ -> ( CamelCaseName.raw field_.name, field_ ))
                        |> Dict.fromList
                        |> Dict.get fieldType.name
                        |> Maybe.andThen (.typeRef >> typeRefToType >> findTypeDef introspectionData)
                        |> Maybe.map (translateField context introspectionData recordContext modulePath fieldType)
                        |> Maybe.withDefault (Err "Couldn't resolve selection type")

                _ ->
                    Err "UnsupportedType"
        )
        |> combine
        |> Result.map
            (\results ->
                { imports =
                    results
                        |> List.map .imports
                        |> List.foldl Set.union Set.empty
                , body =
                    results
                        |> List.map .body
                        |> String.join "\n"
                , correspondElmType = { fieldName = "foo", fieldType = "foo1" }
                , recordContext =
                    results
                        |> List.map .recordContext
                        |> List.foldl
                            (Dict.merge
                                (\key a -> Dict.insert key a)
                                (\key a b -> Dict.insert key a)
                                (\key b -> Dict.insert key b)
                                Dict.empty
                            )
                            Dict.empty
                        |>  Dict.insert targetRecordName (results |> List.map .elmRecordField)
                }
            )
        |> Result.andThen
            (\result ->
                Ok
                    { imports =
                        result.imports
                            |> Set.insert modulePath
                    , body = "SelectionSet.succeed " ++ targetRecordName ++ "\n" ++ result.body
                    , elmRecordField = { name = "foo", type_ = targetRecordName }
                    , recordContext = result.recordContext
                    }
            )

translateOperationDefinition : Context -> IntrospectionData -> OperationDefintion -> TranslationResult
translateOperationDefinition context introspectionData opDef =
    case opDef of
        SelectionSet selectionSet -> Err "Unsupported root level structure"
        Operation operationRecord ->
            let
                selectionSet = operationRecord.selectionSet

                maybeFieldName =
                    case operationRecord.type_ of
                        Query -> Just introspectionData.queryObjectName
                        Mutation -> introspectionData.mutationObjectName
                        Subscription -> introspectionData.subscriptionObjectName

                maybeTypeDef =
                    maybeFieldName
                        |> Maybe.andThen (findTypeDef introspectionData)
            in
            case maybeTypeDef of
                Nothing ->  Err ("Can't find " ++ (maybeFieldName |> Maybe.withDefault "unknown type"))
                Just typeDef ->
                    translateSelectionSet context introspectionData  Dict.empty typeDef selectionSet

transform : { apiSubmodule : List String, scalarCodecsModule : Maybe ModuleName } -> IntrospectionData -> Context -> String -> Result String String
transform options introspectionData context query =
    parse query
        |> Result.mapError (always "Parser Error")
        |> Result.andThen (translateOperationDefinition context introspectionData)
        |> Result.map
            (\{ imports, body, recordContext, elmRecordField } ->
                let
                    modulePath = 
                        List.append options.apiSubmodule [ "Foo" ]
                            |> String.join "."

                in
                "module "++ modulePath ++" exposing (..)\n\n"
                    ++ "import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, hardcoded, with)\n"
                    ++ "import Graphql.Operation exposing (RootQuery)\n"
                    ++ (Set.toList imports
                            |> List.map ((++) "import ")
                            |> String.join "\n"
                       )
                    ++ encodeRecords recordContext
                    ++ "\n\nselection : SelectionSet "++ elmRecordField.type_ ++ " RootQuery"
                    ++ "\nselection = "
                    ++ body
            )


encodeRecords : RecordContext -> String
encodeRecords recordNameToDefinition =
    recordNameToDefinition
        |> Dict.toList
        |> List.map
            (\( recordName, fields ) ->
                "\ntype alias "
                    ++ recordName
                    ++ " =\n{"
                    ++ (fields
                            |> List.map
                                (\{ name, type_ } ->
                                    name ++ " : " ++ type_
                                )
                            |> String.join "\n,"
                       )
                    ++ "\n}"
            )
        |> String.join "\n"