module Page exposing (view)

import Browser exposing (Document)
import Bulma.CDN exposing (..)
import Bulma.Columns exposing (..)
import Bulma.Components exposing (..)
import Bulma.Elements as Elements exposing (..)
import Bulma.Form exposing (..)
import Bulma.Layout as Layout exposing (SectionSpacing(..), container, section)
import Bulma.Modifiers exposing (..)
import Bulma.Modifiers.Typography exposing (textCentered)
import Html exposing (..)
import Html.Attributes exposing (..)



-- VIEW
--view : Html msg -> Document msg


view page =
    { title = "Rapier"
    , body =
        template
            page
    }


headerNavbar : Html msg
headerNavbar =
    fixedNavbar Top
        navbarModifiers
        []
        [ navbarBrand []
            (navbarBurger False
                []
                [ span [] []
                , span [] []
                , span [] []
                ]
            )
            [ navbarItemLink False
                [ href "/" ]
                [ text "o-_)=rapier>" ]
            ]
        , navbarMenu False
            []
            [ navbarStart []
                [ navbarItemLink False [ href "/" ] [ text "Dashboard" ]
                , navbarItemLink False [ href "/settings" ] [ text "Settings" ]
                ]
            ]
        ]


navbarModifiers =
    { color = Dark
    , transparent = False
    }


footer : Html msg
footer =
    Layout.footer []
        [ container []
            [ content Small
                [ textCentered ]
                [ p []
                    [ a [ href "https://github.com/didierofrivia/rapier" ] [ text "o-_)=rapier>" ]
                    , text " is an Open Source project, crafted with loads of <3 and c[_]"
                    ]
                ]
            ]
        ]


template : Html msg -> List (Html msg)
template content =
    [ stylesheet
    , headerNavbar
    , content
    , footer
    ]
