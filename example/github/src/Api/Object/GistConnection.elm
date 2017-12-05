module Api.Object.GistConnection exposing (..)

import Api.Object
import Graphqelm.Argument as Argument exposing (Argument)
import Graphqelm.Field as Field exposing (Field, FieldDecoder)
import Graphqelm.Object as Object exposing (Object)
import Json.Decode as Decode


build : (a -> constructor) -> Object (a -> constructor) Api.Object.GistConnection
build constructor =
    Object.object constructor


edges : FieldDecoder (List Object.GistEdge) Api.Object.GistConnection
edges =
    Field.fieldDecoder "edges" [] (Api.Object.GistEdge.decoder |> Decode.list)


nodes : FieldDecoder (List Object.Gist) Api.Object.GistConnection
nodes =
    Field.fieldDecoder "nodes" [] (Api.Object.Gist.decoder |> Decode.list)


pageInfo : Object pageInfo Api.Object.PageInfo -> FieldDecoder pageInfo Api.Object.GistConnection
pageInfo object =
    Object.single "pageInfo" [] object


totalCount : FieldDecoder String Api.Object.GistConnection
totalCount =
    Field.fieldDecoder "totalCount" [] Decode.string
