module Api.Object.OrganizationInvitationEdge exposing (..)

import Api.Object
import Graphqelm.Argument as Argument exposing (Argument)
import Graphqelm.Field as Field exposing (Field, FieldDecoder)
import Graphqelm.Object as Object exposing (Object)
import Json.Decode as Decode


build : (a -> constructor) -> Object (a -> constructor) Api.Object.OrganizationInvitationEdge
build constructor =
    Object.object constructor


cursor : FieldDecoder String Api.Object.OrganizationInvitationEdge
cursor =
    Field.fieldDecoder "cursor" [] Decode.string


node : Object node Api.Object.OrganizationInvitation -> FieldDecoder node Api.Object.OrganizationInvitationEdge
node object =
    Object.single "node" [] object
