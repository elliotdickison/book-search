module Extra.RemoteData exposing (sendRequestDebounced)

import Http
import Debouncer
import RemoteData exposing (RemoteData)


sendRequestDebounced : String -> Float -> Http.Request a -> Cmd (RemoteData Http.Error a)
sendRequestDebounced key delay request =
    Debouncer.debounce key delay RemoteData.fromResult (Http.toTask request)
