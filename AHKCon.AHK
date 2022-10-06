#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

__new(color, height := "") {

}

__delete() {
     
}

__Cał(Name, Params*){
          Throw, "This method hasn't been defined"
}

__Set(Key, Value){
     If (key == "heights")
          this[key] := RegExReplace(Value, "[^d]+")
}

.__Get(Key) {
     If (Key == "heights")
          return "82ft"
}