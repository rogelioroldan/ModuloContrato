codeunit 50205 "Contrato Reg.-Show Ledger"
{
    TableNo = "Contrato Register";

    trigger OnRun()
    begin
        ContratoLedgEntry.SetRange("Entry No.", Rec."From Entry No.", Rec."To Entry No.");
        PAGE.Run(PAGE::"Contrato Ledger Entries", ContratoLedgEntry);
    end;

    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
}

