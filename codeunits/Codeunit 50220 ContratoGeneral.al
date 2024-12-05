codeunit 50220 "ContratoGeneral"
{
    procedure ShowItemTrackingForContratoPlanningLine(Type: Integer; ID: Code[20]; RefNo: Integer): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        Window: Dialog;
    begin
        //Window.Open(CountingRecordsMsg);
        ItemLedgEntry.SetLoadFields("Serial No.", "Lot No.", "Package No.");
        ItemLedgEntry.SetCurrentKey("Order Type", "Job No.", "Order Line No.", "Entry Type");
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::" ");
        ItemLedgEntry.SetRange("Job No.", ID);
        ItemLedgEntry.SetRange("Order Line No.", RefNo);

        if Type = Database::"Contrato Planning Line" then
            ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::"Negative Adjmt.")
        else
            exit(false);

        if ItemLedgEntry.FindSet() then
            repeat
                if ItemLedgEntry.TrackingExists() then begin
                    TempItemLedgEntry := ItemLedgEntry;
                    TempItemLedgEntry.Insert();
                end
            until ItemLedgEntry.Next() = 0;
        Window.Close();
        if TempItemLedgEntry.IsEmpty() then
            exit(false);

        PAGE.RunModal(PAGE::"Posted Item Tracking Lines", TempItemLedgEntry);
        exit(true);
    end;

}

