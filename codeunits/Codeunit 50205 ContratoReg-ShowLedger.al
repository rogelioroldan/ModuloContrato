codeunit 50205 "Contrato Reg.-Show Ledger"
{
    TableNo = "Contrato Register";

    trigger OnRun()
    begin
        JobLedgEntry.SetRange("Entry No.", Rec."From Entry No.", Rec."To Entry No.");
        PAGE.Run(PAGE::"Contrato Ledger Entries", JobLedgEntry);
    end;

    var
        JobLedgEntry: Record "Contrato Ledger Entry";
}

