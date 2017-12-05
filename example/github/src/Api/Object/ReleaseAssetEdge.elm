module Api.Object.ReleaseAssetEdge exposing (..)

import Api.Object
import Graphqelm.Argument as Argument exposing (Argument)
import Graphqelm.Field as Field exposing (Field, FieldDecoder)
import Graphqelm.Object as Object exposing (Object)
import Json.Decode as Decode


build : (a -> constructor) -> Object (a -> constructor) Api.Object.ReleaseAssetEdge
build constructor =
    Object.object constructor


cursor : FieldDecoder String Api.Object.ReleaseAssetEdge
cursor =
    Field.fieldDecoder "cursor" [] Decode.string


node : Object node Api.Object.ReleaseAsset -> FieldDecoder node Api.Object.ReleaseAssetEdge
node object =
    Object.single "node" [] object
