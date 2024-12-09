codeunit 50214 "Contrato Jnl. Line-Reserve"
{
    Permissions = TableData "Reservation Entry" = rimd;

    trigger OnRun()
    begin
    end;

    var
        ReservMgt: Codeunit "Reservation Management";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        DeleteItemTracking: Boolean;
        CalledFromInvtPutawayPick: Boolean;

        Text002: Label 'must be filled in when a quantity is reserved.';
        Text004: Label 'must not be changed when a quantity is reserved.';

    local procedure FindReservEntry(ContratoJnlLine: Record "Contrato Journal Line"; var ReservEntry: Record "Reservation Entry"): Boolean
    begin
        ReservEntry.InitSortingAndFilters(false);
        ContratoJnlLine.SetReservationFilters(ReservEntry);
        exit(ReservEntry.Find('+'));
    end;

    procedure VerifyChange(var NewContratoJnlLine: Record "Contrato Journal Line"; var OldContratoJnlLine: Record "Contrato Journal Line")
    var
        ContratoJnlLine: Record "Contrato Journal Line";
        TempReservEntry: Record "Reservation Entry";
        ShowError: Boolean;
        HasError: Boolean;
        PointerChanged: Boolean;
    begin
        if NewContratoJnlLine."Line No." = 0 then
            if not ContratoJnlLine.Get(
                 NewContratoJnlLine."Journal Template Name",
                 NewContratoJnlLine."Journal Batch Name",
                 NewContratoJnlLine."Line No.")
            then
                exit;

        NewContratoJnlLine.CalcFields("Reserved Qty. (Base)");
        ShowError := NewContratoJnlLine."Reserved Qty. (Base)" <> 0;

        if NewContratoJnlLine."Posting Date" = 0D then
            if not ShowError then
                HasError := true
            else
                NewContratoJnlLine.FieldError("Posting Date", Text002);

        if NewContratoJnlLine."Contrato No." <> OldContratoJnlLine."Contrato No." then
            if not ShowError then
                HasError := true
            else
                NewContratoJnlLine.FieldError("Contrato No.", Text004);

        if NewContratoJnlLine."Entry Type" <> OldContratoJnlLine."Entry Type" then
            if not ShowError then
                HasError := true
            else
                NewContratoJnlLine.FieldError("Entry Type", Text004);

        if NewContratoJnlLine."Location Code" <> OldContratoJnlLine."Location Code" then
            if not ShowError then
                HasError := true
            else
                NewContratoJnlLine.FieldError("Location Code", Text004);

        if (NewContratoJnlLine.Type = NewContratoJnlLine.Type::Item) and (OldContratoJnlLine.Type = OldContratoJnlLine.Type::Item) then
            if (NewContratoJnlLine."Bin Code" <> OldContratoJnlLine."Bin Code") and
               (not ReservMgt.CalcIsAvailTrackedQtyInBin(
                  NewContratoJnlLine."No.", NewContratoJnlLine."Bin Code",
                  NewContratoJnlLine."Location Code", NewContratoJnlLine."Variant Code",
                  DATABASE::"Contrato Journal Line", NewContratoJnlLine."Entry Type".AsInteger(),
                  NewContratoJnlLine."Journal Template Name", NewContratoJnlLine."Journal Batch Name", 0, NewContratoJnlLine."Line No."))
            then begin
                if ShowError then
                    NewContratoJnlLine.FieldError("Bin Code", Text004);
                HasError := true;
            end;

        if NewContratoJnlLine."Variant Code" <> OldContratoJnlLine."Variant Code" then
            if not ShowError then
                HasError := true
            else
                NewContratoJnlLine.FieldError("Variant Code", Text004);

        if NewContratoJnlLine."Line No." <> OldContratoJnlLine."Line No." then
            HasError := true;

        if NewContratoJnlLine."No." <> OldContratoJnlLine."No." then
            HasError := true;

        OnVerifyChangeOnBeforeHasError(NewContratoJnlLine, OldContratoJnlLine, HasError, ShowError);

        if HasError then begin
            FindReservEntry(NewContratoJnlLine, TempReservEntry);
            TempReservEntry.ClearTrackingFilter();

            PointerChanged := (NewContratoJnlLine."Contrato No." <> OldContratoJnlLine."Contrato No.") or
              (NewContratoJnlLine."Entry Type" <> OldContratoJnlLine."Entry Type") or
              (NewContratoJnlLine."No." <> OldContratoJnlLine."No.");

            if PointerChanged or
               (not TempReservEntry.IsEmpty)
            then begin
                if PointerChanged then begin
                    ReservMgt.SetReservSource(OldContratoJnlLine);
                    ReservMgt.DeleteReservEntries(true, 0);
                    ReservMgt.SetReservSource(NewContratoJnlLine);
                end else begin
                    ReservMgt.SetReservSource(NewContratoJnlLine);
                    ReservMgt.DeleteReservEntries(true, 0);
                end;
                ReservMgt.AutoTrack(NewContratoJnlLine."Quantity (Base)");
            end;
        end;
    end;

    procedure VerifyQuantity(var NewContratoJnlLine: Record "Contrato Journal Line"; var OldContratoJnlLine: Record "Contrato Journal Line")
    var
        ContratoJnlLine: Record "Contrato Journal Line";
    begin
        if NewContratoJnlLine."Line No." = OldContratoJnlLine."Line No." then
            if NewContratoJnlLine."Quantity (Base)" = OldContratoJnlLine."Quantity (Base)" then
                exit;
        if NewContratoJnlLine."Line No." = 0 then
            if not ContratoJnlLine.Get(NewContratoJnlLine."Journal Template Name", NewContratoJnlLine."Journal Batch Name", NewContratoJnlLine."Line No.") then
                exit;
        ReservMgt.SetReservSource(NewContratoJnlLine);
        if NewContratoJnlLine."Qty. per Unit of Measure" <> OldContratoJnlLine."Qty. per Unit of Measure" then
            ReservMgt.ModifyUnitOfMeasure();
        if NewContratoJnlLine."Quantity (Base)" * OldContratoJnlLine."Quantity (Base)" < 0 then
            ReservMgt.DeleteReservEntries(true, 0)
        else
            ReservMgt.DeleteReservEntries(false, NewContratoJnlLine."Quantity (Base)");
    end;

    procedure RenameLine(var NewContratoJnlLine: Record "Contrato Journal Line"; var OldContratoJnlLine: Record "Contrato Journal Line")
    begin
        ReservEngineMgt.RenamePointer(DATABASE::"Contrato Journal Line",
          OldContratoJnlLine."Entry Type".AsInteger(),
          OldContratoJnlLine."Journal Template Name",
          OldContratoJnlLine."Journal Batch Name",
          0,
          OldContratoJnlLine."Line No.",
          NewContratoJnlLine."Entry Type".AsInteger(),
          NewContratoJnlLine."Journal Template Name",
          NewContratoJnlLine."Journal Batch Name",
          0,
          NewContratoJnlLine."Line No.");
    end;

    procedure DeleteLineConfirm(var ContratoJnlLine: Record "Contrato Journal Line"): Boolean
    begin
        if not ContratoJnlLine.ReservEntryExist() then
            exit(true);

        ReservMgt.SetReservSource(ContratoJnlLine);
        if ReservMgt.DeleteItemTrackingConfirm() then
            DeleteItemTracking := true;

        exit(DeleteItemTracking);
    end;

    procedure DeleteLine(var ContratoJnlLine: Record "Contrato Journal Line")
    begin
        if ContratoJnlLine.Type = ContratoJnlLine.Type::Item then begin
            ReservMgt.SetReservSource(ContratoJnlLine);
            if DeleteItemTracking then
                ReservMgt.SetItemTrackingHandling(1); // Allow Deletion
            ReservMgt.DeleteReservEntries(true, 0);
        end;
    end;

    procedure CallItemTracking(var ContratoJnlLine: Record "Contrato Journal Line"; IsReclass: Boolean)
    var
        TrackingSpecification: Record "Tracking Specification";
        ItemTrackingLines: Page "Item Tracking Lines";
    begin
        //TrackingSpecification.InitFromContratoJnlLine(ContratoJnlLine);
        if IsReclass then
            ItemTrackingLines.SetRunMode(Enum::"Item Tracking Run Mode"::Reclass);
        ItemTrackingLines.SetSourceSpec(TrackingSpecification, ContratoJnlLine."Posting Date");
        ItemTrackingLines.SetInbound(ContratoJnlLine.IsInbound());
        ItemTrackingLines.RunModal();
    end;

    internal procedure TransContratoJnlLineToItemJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; var ItemJnlLine: Record "Item Journal Line"; TransferQty: Decimal; CalledFromInvtPutawayPickVal: Boolean): Decimal
    begin
        CalledFromInvtPutawayPick := CalledFromInvtPutawayPickVal;
        exit(TransContratoJnlLineToItemJnlLine(ContratoJnlLine, ItemJnlLine, TransferQty));
    end;

    procedure TransContratoJnlLineToItemJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; var ItemJnlLine: Record "Item Journal Line"; TransferQty: Decimal): Decimal
    var
        OldReservEntry: Record "Reservation Entry";
    begin
        if not FindReservEntry(ContratoJnlLine, OldReservEntry) then
            exit(TransferQty);
        OldReservEntry.Lock();
        // Handle Item Tracking on drop shipment:
        Clear(CreateReservEntry);

        ItemJnlLine.TestItemFields(ContratoJnlLine."No.", ContratoJnlLine."Variant Code", ContratoJnlLine."Location Code");

        if TransferQty = 0 then
            exit;

        //Do not transfer remaining quantity when posting from Inventory Pick as the entry is created during posting process of Item through Item Jnl Line.
        //CreateReservEntry.SetCalledFromInvtPutawayPick(CalledFromInvtPutawayPick);

        if ReservEngineMgt.InitRecordSet(OldReservEntry) then
            repeat
                OldReservEntry.TestItemFields(ContratoJnlLine."No.", ContratoJnlLine."Variant Code", ContratoJnlLine."Location Code");

                TransferQty := CreateReservEntry.TransferReservEntry(DATABASE::"Item Journal Line",
                    ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
                    ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.",
                    ItemJnlLine."Qty. per Unit of Measure", OldReservEntry, TransferQty);

            until (ReservEngineMgt.NEXTRecord(OldReservEntry) = 0) or (TransferQty = 0);

        exit(TransferQty);
    end;

    local procedure MatchThisTable(TableID: Integer): Boolean
    begin
        exit(TableID = DATABASE::"Contrato Journal Line");
    end;

    local procedure GetSourceValue(ReservEntry: Record "Reservation Entry"; var SourceRecRef: RecordRef; ReturnOption: Option "Net Qty. (Base)","Gross Qty. (Base)"): Decimal
    var
        ContratoJnlLine: Record "Contrato Journal Line";
    begin
        ContratoJnlLine.Get(ReservEntry."Source ID", ReservEntry."Source Batch Name", ReservEntry."Source Ref. No.");
        SourceRecRef.GetTable(ContratoJnlLine);
        case ReturnOption of
            ReturnOption::"Net Qty. (Base)":
                exit(ContratoJnlLine."Quantity (Base)");
            ReturnOption::"Gross Qty. (Base)":
                exit(ContratoJnlLine."Quantity (Base)");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnGetSourceRecordValue', '', false, false)]
    local procedure OnGetSourceRecordValue(var ReservEntry: Record "Reservation Entry"; ReturnOption: Option; var ReturnQty: Decimal; var SourceRecRef: RecordRef)
    begin
        if MatchThisTable(ReservEntry."Source Type") then
            ReturnQty := GetSourceValue(ReservEntry, SourceRecRef, ReturnOption);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifyChangeOnBeforeHasError(NewContratoJnlLine: Record "Contrato Journal Line"; OldContratoJnlLine: Record "Contrato Journal Line"; var HasError: Boolean; var ShowError: Boolean)
    begin
    end;
}

