module Api.Object.ProjectEdge exposing (..)

import Api.Object
import Graphqelm.Argument as Argument exposing (Argument)
import Graphqelm.Field as Field exposing (Field, FieldDecoder)
import Graphqelm.Object as Object exposing (Object)
import Json.Decode as Decode


build : (a -> constructor) -> Object (a -> constructor) Api.Object.ProjectEdge
build constructor =
    Object.object constructor


cursor : FieldDecoder String Api.Object.ProjectEdge
cursor =
    Field.fieldDecoder "cursor" [] Decode.string


node : Object node Api.Object.Project -> FieldDecoder node Api.Object.ProjectEdge
node object =
    Object.single "node" [] object
