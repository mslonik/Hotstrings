
Sub PrintAutoCorrect()

'
'  Source: https://wordribbon.tips.net/T009084_Printing_a_List_of_AutoCorrect_Entries.html
'
'
    Dim a As AutoCorrectEntry

    Selection.ParagraphFormat.TabStops.ClearAll
    Selection.ParagraphFormat.TabStops.Add Position:=72, _
      Alignment:=wdAlignTabLeft, Leader:=wdTabLeaderSpaces

    For Each a In Application.AutoCorrect.Entries
        Selection.TypeText a.Name & vbTab & a.Value & " " & vbCr
    Next
End Sub