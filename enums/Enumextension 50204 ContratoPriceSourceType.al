enumextension 50204 "Price Source Type Ext" extends "Price Source Type"
{

    value(33; Contrato)
    {
        Caption = 'Contrato';
        Implementation = "Price Source" = "Price Source - Job", "Price Source Group" = "Price Source Group - Contrato";
    }
    value(34; "Contrato Task")
    {
        Caption = 'Contrato Task';
        Implementation = "Price Source" = "Price Source - Job Task", "Price Source Group" = "Price Source Group - Contrato";
    }
}