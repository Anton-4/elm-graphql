-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Github.Interface.Lockable exposing (Fragments, activeLockReason, fragments, locked, maybeFragments, selection)

import Github.Enum.LockReason
import Github.InputObject
import Github.Interface
import Github.Object
import Github.Scalar
import Github.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (FragmentSelectionSet(..), SelectionSet(..))
import Json.Decode as Decode


{-| Select fields to build up a SelectionSet for this Interface.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) Github.Interface.Lockable
selection constructor =
    Object.selection constructor


type alias Fragments decodesTo =
    { onIssue : SelectionSet decodesTo Github.Object.Issue
    , onPullRequest : SelectionSet decodesTo Github.Object.PullRequest
    }


{-| Build an exhaustive selection of type-specific fragments.
-}
fragments :
    Fragments decodesTo
    -> SelectionSet decodesTo Github.Interface.Lockable
fragments selections =
    Object.exhuastiveFragmentSelection
        [ Object.buildFragment "Issue" selections.onIssue
        , Object.buildFragment "PullRequest" selections.onPullRequest
        ]


{-| Can be used to create a non-exhuastive set of fragments by using the record
update syntax to add `SelectionSet`s for the types you want to handle.
-}
maybeFragments : Fragments (Maybe a)
maybeFragments =
    { onIssue = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    , onPullRequest = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    }


{-| Reason that the conversation was locked.
-}
activeLockReason : Field (Maybe Github.Enum.LockReason.LockReason) Github.Interface.Lockable
activeLockReason =
    Object.fieldDecoder "activeLockReason" [] (Github.Enum.LockReason.decoder |> Decode.nullable)


{-| `true` if the object is locked
-}
locked : Field Bool Github.Interface.Lockable
locked =
    Object.fieldDecoder "locked" [] Decode.bool
