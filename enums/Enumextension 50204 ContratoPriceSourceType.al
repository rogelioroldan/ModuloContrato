enumextension 50204 "Price Source Type Ext" extends "Price Source Type"
{

    value(33; Contrato)
    {
        Caption = 'Project';
        Implementation = "Price Source" = "Price Source - Job", "Price Source Group" = "Price Source Group - Job";
    }
    value(34; "Contrato Task")
    {
        Caption = 'Project Task';
        Implementation = "Price Source" = "Price Source - Job Task", "Price Source Group" = "Price Source Group - Job";
    }
}