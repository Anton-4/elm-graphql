module Graphqelm.Encode exposing (Value, bool, enum, int, list, maybe, maybeObject, null, object, optional, serialize, string)

{-| `Graphqelm.Encode.Value`s are low-level details used by generated code.
They are only used by the code generated by the `graphqelm` CLI tool.

@docs null, bool, enum, int, list, string, object, maybe, maybeObject, optional
@docs serialize
@docs Value

-}

import Graphqelm.OptionalArgument as OptionalArgument exposing (OptionalArgument)
import Json.Encode


{-| Values
-}
type Value
    = EnumValue String
    | Json Json.Encode.Value
    | List (List Value)
    | Object (List ( String, Value ))


{-| Encode a list of key-value pairs into an object
-}
object : List ( String, Value ) -> Value
object value =
    Object value


{-| Encode a list of key-value pairs into an object
-}
maybeObject : List ( String, Maybe Value ) -> Value
maybeObject maybeValues =
    maybeValues
        |> List.filterMap
            (\( key, value ) ->
                case value of
                    Just actualValue ->
                        Just ( key, actualValue )

                    Nothing ->
                        Nothing
            )
        |> Object


{-| Encode a list of key-value pairs into an object
-}
optional : OptionalArgument a -> (a -> Value) -> Maybe Value
optional optionalValue toValue =
    case optionalValue of
        OptionalArgument.Present value ->
            toValue value
                |> Just

        OptionalArgument.Absent ->
            Nothing

        OptionalArgument.Null ->
            Just null


{-| Encode an int
-}
int : Int -> Value
int value =
    Json.Encode.int value
        |> Json


{-| Encode null
-}
null : Value
null =
    Json.Encode.null
        |> Json


{-| Encode a bool
-}
bool : Bool -> Value
bool bool =
    Json.Encode.bool bool
        |> Json


{-| Encode a string
-}
string : String -> Value
string string =
    Json.Encode.string string
        |> Json


{-| Encode an enum. The first argument is the toString function for that enum.
-}
enum : (a -> String) -> a -> Value
enum enumToString enum =
    EnumValue (enumToString enum)


{-| Encode a list of Values
-}
list : (a -> Value) -> List a -> Value
list toValue list =
    list
        |> List.map toValue
        |> List


{-| Encode a Maybe. Uses encoder for `Just`, or `Encode.null` for `Nothing`.
-}
maybe : (a -> Value) -> Maybe a -> Value
maybe encoder =
    Maybe.map encoder >> Maybe.withDefault null


{-| Low-level function for serializing a `Graphqelm.Encode.Value`s.
-}
serialize : Value -> String
serialize value =
    case value of
        EnumValue enumValue ->
            enumValue

        Json json ->
            Json.Encode.encode 0 json

        List values ->
            "["
                ++ (List.map serialize values |> String.join ", ")
                ++ "]"

        Object keyValuePairs ->
            "{"
                ++ (List.map (\( key, objectValue ) -> key ++ ": " ++ serialize objectValue)
                        keyValuePairs
                        |> String.join ", "
                   )
                ++ "}"
