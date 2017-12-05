module Api.Object.RequestReviewsPayload exposing (..)

import Api.Object
import Graphqelm.Argument as Argument exposing (Argument)
import Graphqelm.Field as Field exposing (Field, FieldDecoder)
import Graphqelm.Object as Object exposing (Object)
import Json.Decode as Decode


build : (a -> constructor) -> Object (a -> constructor) Api.Object.RequestReviewsPayload
build constructor =
    Object.object constructor


clientMutationId : FieldDecoder String Api.Object.RequestReviewsPayload
clientMutationId =
    Field.fieldDecoder "clientMutationId" [] Decode.string


pullRequest : Object pullRequest Api.Object.PullRequest -> FieldDecoder pullRequest Api.Object.RequestReviewsPayload
pullRequest object =
    Object.single "pullRequest" [] object


requestedReviewersEdge : Object requestedReviewersEdge Api.Object.UserEdge -> FieldDecoder requestedReviewersEdge Api.Object.RequestReviewsPayload
requestedReviewersEdge object =
    Object.single "requestedReviewersEdge" [] object
