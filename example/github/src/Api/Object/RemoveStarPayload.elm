module Api.Object.RemoveStarPayload exposing (..)

import Api.Object
import Graphqelm.Argument as Argument exposing (Argument)
import Graphqelm.Field as Field exposing (Field, FieldDecoder)
import Graphqelm.Object as Object exposing (Object)
import Json.Decode as Decode


build : (a -> constructor) -> Object (a -> constructor) Api.Object.RemoveStarPayload
build constructor =
    Object.object constructor


clientMutationId : FieldDecoder String Api.Object.RemoveStarPayload
clientMutationId =
    Field.fieldDecoder "clientMutationId" [] Decode.string


starrable : Object starrable Api.Object.Starrable -> FieldDecoder starrable Api.Object.RemoveStarPayload
starrable object =
    Object.single "starrable" [] object
