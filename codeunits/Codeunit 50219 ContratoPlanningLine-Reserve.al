codeunit 50219 "Contrato Planning Line-Reserve"
{
    Permissions = TableData "Reservation Entry" = rimd,
                  TableData "Planning Assignment" = rimd;

    trigger OnRun()
    begin
    end;

    var
        FromTrackingSpecification: Record "Tracking Specification";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
        ReservationManagement: Codeunit "Reservation Management";

        Text000Err: Label 'Reserved quantity cannot be greater than %1.', Comment = '%1 - qualtity';
        Text002Err: Label 'must be filled in when a quantity is reserved', Comment = 'starts with "Planning Date"';
        Text004Err: Label 'must not be changed when a quantity is reserved', Comment = 'starts with some field name';
        Text005Err: Label 'Codeunit is not initialized correctly.';
        InvalidLineTypeErr: Label 'must be %1 or %2', Comment = '%1 and %2 are line type options, fx. Budget or Billable';
        SummaryTypeTxt: Label '%1, %2', Locked = true;

    procedure CreateReservation(ContratoPlanningLine: Record "Contrato Planning Line"; Description: Text[100]; ExpectedReceiptDate: Date; Quantity: Decimal; QuantityBase: Decimal; ForReservEntry: Record "Reservation Entry")
    var
        PlanningDate: Date;
        SignFactor: Integer;
    begin
        if FromTrackingSpecification."Source Type" = 0 then
            Error(Text005Err);

        ContratoPlanningLine.TestField(Type, ContratoPlanningLine.Type::Item);
        ContratoPlanningLine.TestField("No.");
        ContratoPlanningLine.TestField("Planning Date");

        ContratoPlanningLine.CalcFields("Reserved Qty. (Base)");
        CheckReservedQtyBase(ContratoPlanningLine, QuantityBase);

        ContratoPlanningLine.TestField("Variant Code", FromTrackingSpecification."Variant Code");
        ContratoPlanningLine.TestField("Location Code", FromTrackingSpecification."Location Code");

        SignFactor := -1;

        if QuantityBase * SignFactor < 0 then
            PlanningDate := ContratoPlanningLine."Planning Date"
        else begin
            PlanningDate := ExpectedReceiptDate;
            ExpectedReceiptDate := ContratoPlanningLine."Planning Date";
        end;

        CreateReservEntry.CreateReservEntryFor(
          Database::"Contrato Planning Line", ContratoPlanningLine.Status.AsInteger(),
          ContratoPlanningLine."Contrato No.", '', 0, ContratoPlanningLine."Contrato Contract Entry No.", ContratoPlanningLine."Qty. per Unit of Measure",
          Quantity, QuantityBase, ForReservEntry);
        CreateReservEntry.CreateReservEntryFrom(FromTrackingSpecification);
        CreateReservEntry.CreateReservEntry(
          ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Location Code",
          Description, ExpectedReceiptDate, PlanningDate, 0);

        FromTrackingSpecification."Source Type" := 0;
    end;

    procedure CreateBindingReservation(ContratoPlanningLine: Record "Contrato Planning Line"; Description: Text[100]; ExpectedReceiptDate: Date; Quantity: Decimal; QuantityBase: Decimal)
    var
        DummyReservationEntry: Record "Reservation Entry";
    begin
        CreateReservation(ContratoPlanningLine, Description, ExpectedReceiptDate, Quantity, QuantityBase, DummyReservationEntry);
    end;

    procedure CreateReservationSetFrom(TrackingSpecification: Record "Tracking Specification")
    begin
        FromTrackingSpecification := TrackingSpecification;
    end;

    local procedure CheckReservedQtyBase(ContratoPlanningLine: Record "Contrato Planning Line"; QuantityBase: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckReservedQtyBase(ContratoPlanningLine, IsHandled, QuantityBase);
        if IsHandled then
            exit;

        if Abs(ContratoPlanningLine."Remaining Qty. (Base)") < Abs(ContratoPlanningLine."Reserved Qty. (Base)") + QuantityBase then
            Error(
              Text000Err,
              Abs(ContratoPlanningLine."Remaining Qty. (Base)") - Abs(ContratoPlanningLine."Reserved Qty. (Base)"));
    end;

    procedure SetBinding(Binding: Enum "Reservation Binding")
    begin
        CreateReservEntry.SetBinding(Binding);
    end;

    procedure CallItemTracking(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        TrackingSpecification: Record "Tracking Specification";
        ItemTrackingDocManagement: Codeunit "ContratoGeneral";
        ItemTrackingLines: Page "Item Tracking Lines";
    begin
        // Throw error if "Type" != "Item" or "Line Type" != "Budget" or "Budget and Billable"
        ContratoPlanningLine.TestField(Type, ContratoPlanningLine.Type::Item);
        if not (ContratoPlanningLine."Line Type" in [Enum::"ContratoPlanningLineLineType"::"Both Budget and Billable", Enum::"ContratoPlanningLineLineType"::Budget]) then
            ContratoPlanningLine.FieldError("Line Type", StrSubstNo(InvalidLineTypeErr, Enum::"ContratoPlanningLineLineType"::Budget, Enum::"ContratoPlanningLineLineType"::"Both Budget and Billable"));

        if ContratoPlanningLine.Status = ContratoPlanningLine.Status::Completed then
            ItemTrackingDocManagement.ShowItemTrackingForContratoPlanningLine(DATABASE::"Contrato Planning Line", ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Contract Entry No.")
        else begin
            ContratoPlanningLine.TestField("No.");
            //TrackingSpecification.InitFromContratoPlanningLine(ContratoPlanningLine);
            ItemTrackingLines.SetSourceSpec(TrackingSpecification, ContratoPlanningLine."Planning Due Date");
            ItemTrackingLines.SetInbound(ContratoPlanningLine.IsInbound());
            ItemTrackingLines.RunModal();
        end;
    end;

    procedure ReservQuantity(ContratoPlanningLine: Record "Contrato Planning Line"; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal)
    begin
        case ContratoPlanningLine.Status of
            ContratoPlanningLine.Status::Planning,
            ContratoPlanningLine.Status::Quote,
            ContratoPlanningLine.Status::Order,
            ContratoPlanningLine.Status::Completed:
                begin
                    QtyToReserve := ContratoPlanningLine."Remaining Qty.";
                    QtyToReserveBase := ContratoPlanningLine."Remaining Qty. (Base)";
                end;
        end;

        OnAfterReservQuantity(ContratoPlanningLine, QtyToReserve, QtyToReserveBase);
    end;

    procedure Caption(ContratoPlanningLine: Record "Contrato Planning Line") CaptionText: Text
    begin
        CaptionText := ContratoPlanningLine.GetSourceCaption();
    end;

    procedure FindReservEntry(ContratoPlanningLine: Record "Contrato Planning Line"; var ReservationEntry: Record "Reservation Entry"): Boolean
    begin
        ReservationEntry.InitSortingAndFilters(false);
        ContratoPlanningLine.SetReservationFilters(ReservationEntry);
        exit(ReservationEntry.FindLast());
    end;

    procedure GetReservedQtyFromInventory(ContratoPlanningLine: Record "Contrato Planning Line"): Decimal
    var
        ReservationEntry: Record "Reservation Entry";
        QtyReservedFromItemLedger: Query "Qty. Reserved From Item Ledger";
    begin
        ContratoPlanningLine.SetReservationEntry(ReservationEntry);
        //QtyReservedFromItemLedger.SetSourceFilter(ReservationEntry);
        QtyReservedFromItemLedger.Open();
        if QtyReservedFromItemLedger.Read() then
            exit(QtyReservedFromItemLedger.Quantity__Base_);

        exit(0);
    end;

    procedure GetReservedQtyFromInventory(Contrato: Record Contrato): Decimal
    var
        ReservationEntry: Record "Reservation Entry";
        QtyReservedFromItemLedger: Query "Qty. Reserved From Item Ledger";
    begin
        ReservationEntry.SetSource(Database::"Contrato Planning Line", Contrato.Status.AsInteger(), Contrato."No.", 0, '', 0);
        //QtyReservedFromItemLedger.SetSourceFilter(ReservationEntry);
        QtyReservedFromItemLedger.Open();
        if QtyReservedFromItemLedger.Read() then
            exit(QtyReservedFromItemLedger.Quantity__Base_);

        exit(0);
    end;

    procedure VerifyChange(var NewContratoPlanningLine: Record "Contrato Planning Line"; var OldContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ReservationEntry: Record "Reservation Entry";
        ShowError: Boolean;
        HasError: Boolean;
    begin
        if (NewContratoPlanningLine.Type <> NewContratoPlanningLine.Type::Item) and (OldContratoPlanningLine.Type <> OldContratoPlanningLine.Type::Item) then
            exit;
        if NewContratoPlanningLine."Contrato Contract Entry No." = 0 then
            if not ContratoPlanningLine.Get(
                 NewContratoPlanningLine."Contrato No.",
                 NewContratoPlanningLine."Contrato Task No.",
                 NewContratoPlanningLine."Line No.")
            then
                exit;

        NewContratoPlanningLine.CalcFields("Reserved Qty. (Base)");
        ShowError := NewContratoPlanningLine."Reserved Qty. (Base)" <> 0;

        if NewContratoPlanningLine."Usage Link" <> OldContratoPlanningLine."Usage Link" then begin
            if ShowError then
                NewContratoPlanningLine.FieldError("Usage Link", Text004Err);
            HasError := true;
        end;

        if (NewContratoPlanningLine."Planning Date" = 0D) and (OldContratoPlanningLine."Planning Date" <> 0D) then begin
            if ShowError then
                NewContratoPlanningLine.FieldError("Planning Date", Text002Err);
            HasError := true;
        end;

        if NewContratoPlanningLine."No." <> OldContratoPlanningLine."No." then begin
            if ShowError then
                NewContratoPlanningLine.FieldError("No.", Text004Err);
            HasError := true;
        end;

        if NewContratoPlanningLine."Variant Code" <> OldContratoPlanningLine."Variant Code" then begin
            if ShowError then
                NewContratoPlanningLine.FieldError("Variant Code", Text004Err);
            HasError := true;
        end;

        if NewContratoPlanningLine."Location Code" <> OldContratoPlanningLine."Location Code" then begin
            if ShowError then
                NewContratoPlanningLine.FieldError("Location Code", Text004Err);
            HasError := true;
        end;

        if NewContratoPlanningLine."Line No." <> OldContratoPlanningLine."Line No." then
            HasError := true;

        if NewContratoPlanningLine.Type <> OldContratoPlanningLine.Type then begin
            if ShowError then
                NewContratoPlanningLine.FieldError(Type, Text004Err);
            HasError := true;
        end;

        VerifyBinInContratoPlanningLine(NewContratoPlanningLine, OldContratoPlanningLine, HasError);

        OnVerifyChangeOnBeforeHasErrorCheck(NewContratoPlanningLine, OldContratoPlanningLine, HasError, ShowError);

        if HasError then
            if (NewContratoPlanningLine."No." <> OldContratoPlanningLine."No.") or
               FindReservEntry(NewContratoPlanningLine, ReservationEntry)
            then begin
                if (NewContratoPlanningLine."No." <> OldContratoPlanningLine."No.") or (NewContratoPlanningLine.Type <> OldContratoPlanningLine.Type) then begin
                    ReservationManagement.SetReservSource(OldContratoPlanningLine);
                    ReservationManagement.DeleteReservEntries(true, 0);
                    ReservationManagement.SetReservSource(NewContratoPlanningLine);
                end else begin
                    ReservationManagement.SetReservSource(NewContratoPlanningLine);
                    ReservationManagement.DeleteReservEntries(true, 0);
                end;
                ReservationManagement.AutoTrack(NewContratoPlanningLine."Remaining Qty. (Base)");
            end;

        if HasError or (NewContratoPlanningLine."Planning Date" <> OldContratoPlanningLine."Planning Date")
        then begin
            AssignForPlanning(NewContratoPlanningLine);
            if (NewContratoPlanningLine."No." <> OldContratoPlanningLine."No.") or
               (NewContratoPlanningLine."Variant Code" <> OldContratoPlanningLine."Variant Code") or
               (NewContratoPlanningLine."Location Code" <> OldContratoPlanningLine."Location Code")
            then
                AssignForPlanning(OldContratoPlanningLine);
        end;
    end;

    local procedure VerifyBinInContratoPlanningLine(var NewContratoPlanningLine: Record "Contrato Planning Line"; var OldContratoPlanningLine: Record "Contrato Planning Line"; var HasError: Boolean)
    begin
        if (NewContratoPlanningLine.Type = NewContratoPlanningLine.Type::Item) and (OldContratoPlanningLine.Type = OldContratoPlanningLine.Type::Item) then
            if (NewContratoPlanningLine."Bin Code" <> OldContratoPlanningLine."Bin Code") and
               (not ReservationManagement.CalcIsAvailTrackedQtyInBin(
                  NewContratoPlanningLine."No.", NewContratoPlanningLine."Bin Code",
                  NewContratoPlanningLine."Location Code", NewContratoPlanningLine."Variant Code",
                  DATABASE::"Contrato Planning Line", NewContratoPlanningLine.Status.AsInteger(),
                  NewContratoPlanningLine."Contrato No.", '', 0,
                  NewContratoPlanningLine."Contrato Contract Entry No."))
            then
                HasError := true;
    end;

    procedure VerifyQuantity(var NewContratoPlanningLine: Record "Contrato Planning Line"; var OldContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeVerifyQuantity(NewContratoPlanningLine, OldContratoPlanningLine, IsHandled);
        if IsHandled then
            exit;

        if NewContratoPlanningLine.Type <> NewContratoPlanningLine.Type::Item then
            exit;
        if NewContratoPlanningLine.Status = OldContratoPlanningLine.Status then
            if NewContratoPlanningLine."Line No." = OldContratoPlanningLine."Line No." then
                if NewContratoPlanningLine."Quantity (Base)" = OldContratoPlanningLine."Quantity (Base)" then
                    exit;
        if NewContratoPlanningLine."Line No." = 0 then
            if not ContratoPlanningLine.Get(NewContratoPlanningLine."Contrato No.", NewContratoPlanningLine."Contrato Task No.", NewContratoPlanningLine."Line No.") then
                exit;
        ReservationManagement.SetReservSource(NewContratoPlanningLine);
        if NewContratoPlanningLine."Qty. per Unit of Measure" <> OldContratoPlanningLine."Qty. per Unit of Measure" then
            ReservationManagement.ModifyUnitOfMeasure();
        if NewContratoPlanningLine."Remaining Qty. (Base)" * OldContratoPlanningLine."Remaining Qty. (Base)" < 0 then
            ReservationManagement.DeleteReservEntries(true, 0)
        else
            ReservationManagement.DeleteReservEntries(false, NewContratoPlanningLine."Remaining Qty. (Base)");
        ReservationManagement.ClearSurplus();
        ReservationManagement.AutoTrack(NewContratoPlanningLine."Remaining Qty. (Base)");
        AssignForPlanning(NewContratoPlanningLine);
    end;

    procedure TransferContratoLineToItemJnlLine(var ContratoPlanningLine: Record "Contrato Planning Line"; var NewItemJournalLine: Record "Item Journal Line"; TransferQty: Decimal): Decimal
    var
        OldReservationEntry: Record "Reservation Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingFilterIsSet: Boolean;
        EndLoop: Boolean;
        TrackedQty: Decimal;
        UnTrackedQty: Decimal;
        xTransferQty: Decimal;
    begin
        if not FindReservEntry(ContratoPlanningLine, OldReservationEntry) then
            exit(TransferQty);

        // Store initial values
        OldReservationEntry.CalcSums("Quantity (Base)");
        TrackedQty := -OldReservationEntry."Quantity (Base)";
        xTransferQty := TransferQty;

        OldReservationEntry.Lock();

        // Handle Item Tracking on Contrato planning line:
        Clear(CreateReservEntry);
        if NewItemJournalLine."Entry Type" = NewItemJournalLine."Entry Type"::"Negative Adjmt." then
            if NewItemJournalLine.TrackingExists() then begin
                // Try to match against Item Tracking on the Contrato planning line:
                OldReservationEntry.SetTrackingFilterFromItemJnlLine(NewItemJournalLine);
                if OldReservationEntry.IsEmpty() then
                    OldReservationEntry.ClearTrackingFilter()
                else
                    ItemTrackingFilterIsSet := true;
            end;

        NewItemJournalLine.TestItemFields(ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Location Code");

        if TransferQty = 0 then
            exit;

        ItemTrackingSetup.CopyTrackingFromItemJnlLine(NewItemJournalLine);
        if ReservationEngineMgt.InitRecordSet(OldReservationEntry, ItemTrackingSetup) then
            repeat
                OldReservationEntry.TestItemFields(ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Location Code");

                if NewItemJournalLine."Entry Type" = NewItemJournalLine."Entry Type"::"Negative Adjmt." then
                    // Set the tracking for the item journal inside the loop as it is cleared within TransferReservEntry
                    CreateReservEntry.SetNewTrackingFromItemJnlLine(NewItemJournalLine);

                TransferQty :=
                  CreateReservEntry.TransferReservEntry(DATABASE::"Item Journal Line",
                    NewItemJournalLine."Entry Type".AsInteger(), NewItemJournalLine."Journal Template Name", NewItemJournalLine."Journal Batch Name", 0,
                    NewItemJournalLine."Line No.", NewItemJournalLine."Qty. per Unit of Measure", OldReservationEntry, TransferQty);

                EndLoop := TransferQty = 0;
                if not EndLoop then
                    if ReservationEngineMgt.NEXTRecord(OldReservationEntry) = 0 then
                        if ItemTrackingFilterIsSet then begin
                            OldReservationEntry.ClearTrackingFilter();
                            ItemTrackingFilterIsSet := false;
                            EndLoop := not ReservationEngineMgt.InitRecordSet(OldReservationEntry);
                        end else
                            EndLoop := true;
            until EndLoop;

        // Handle remaining transfer quantity
        if TransferQty <> 0 then begin
            TrackedQty -= (xTransferQty - TransferQty);
            UnTrackedQty := ContratoPlanningLine."Remaining Qty. (Base)" - TrackedQty;
            if TransferQty > UnTrackedQty then begin
                ReservationManagement.SetReservSource(ContratoPlanningLine);
                ReservationManagement.DeleteReservEntries(false, ContratoPlanningLine."Remaining Qty. (Base)");
            end;
        end;
        exit(TransferQty);
    end;

    procedure DeleteLine(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        DeleteLineInternal(ContratoPlanningLine, true);
    end;

    internal procedure DeleteLineInternal(var ContratoPlanningLine: Record "Contrato Planning Line"; ConfirmFirst: Boolean)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationManagement.SetReservSource(ContratoPlanningLine);

        ReservationEntry.InitSortingAndFilters(false);
        ContratoPlanningLine.SetReservationFilters(ReservationEntry);
        if not ReservationEntry.IsEmpty() then
            if ConfirmFirst then begin
                if ReservationManagement.DeleteItemTrackingConfirm() then
                    ReservationManagement.SetItemTrackingHandling(1);
            end else
                ReservationManagement.SetItemTrackingHandling(1);
        ReservationManagement.DeleteReservEntries(true, 0);
        ContratoPlanningLine.CalcFields("Reserved Qty. (Base)");
        AssignForPlanning(ContratoPlanningLine);
    end;

    local procedure AssignForPlanning(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        PlanningAssignment: Record "Planning Assignment";
    begin
        if ContratoPlanningLine.Status <> ContratoPlanningLine.Status::Order then
            exit;
        if ContratoPlanningLine.Type <> ContratoPlanningLine.Type::Item then
            exit;
        if ContratoPlanningLine."No." <> '' then
            PlanningAssignment.ChkAssignOne(
                ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Location Code", ContratoPlanningLine."Planning Date");
    end;

    procedure BindToPurchase(ContratoPlanningLine: Record "Contrato Planning Line"; PurchaseLine: Record "Purchase Line"; ReservQty: Decimal; ReservQtyBase: Decimal)
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
    begin
        SetBinding(ReservationEntry.Binding::"Order-to-Order");
        TrackingSpecification.InitTrackingSpecification(
          DATABASE::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", '', 0, PurchaseLine."Line No.",
          PurchaseLine."Variant Code", PurchaseLine."Location Code", PurchaseLine."Qty. per Unit of Measure");
        CreateReservationSetFrom(TrackingSpecification);
        CreateBindingReservation(ContratoPlanningLine, PurchaseLine.Description, PurchaseLine."Expected Receipt Date", ReservQty, ReservQtyBase);
    end;

    procedure BindToRequisition(ContratoPlanningLine: Record "Contrato Planning Line"; RequisitionLine: Record "Requisition Line"; ReservQty: Decimal; ReservQtyBase: Decimal)
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
    begin
        SetBinding(ReservationEntry.Binding::"Order-to-Order");
        TrackingSpecification.InitTrackingSpecification(
          DATABASE::"Requisition Line",
          0, RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name", 0, RequisitionLine."Line No.",
          RequisitionLine."Variant Code", RequisitionLine."Location Code", RequisitionLine."Qty. per Unit of Measure");
        CreateReservationSetFrom(TrackingSpecification);
        CreateBindingReservation(ContratoPlanningLine, RequisitionLine.Description, RequisitionLine."Due Date", ReservQty, ReservQtyBase);
    end;

    procedure BindToTransfer(ContratoPlanningLine: Record "Contrato Planning Line"; TransferLine: Record "Transfer Line"; ReservQty: Decimal; ReservQtyBase: Decimal)
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
    begin
        SetBinding(ReservationEntry.Binding::"Order-to-Order");
        TrackingSpecification.InitTrackingSpecification(
          DATABASE::"Transfer Line", 1, TransferLine."Document No.", '', 0, TransferLine."Line No.",
          TransferLine."Variant Code", TransferLine."Transfer-to Code", TransferLine."Qty. per Unit of Measure");
        CreateReservationSetFrom(TrackingSpecification);
        CreateBindingReservation(ContratoPlanningLine, TransferLine.Description, TransferLine."Receipt Date", ReservQty, ReservQtyBase);
    end;

    procedure BindToProdOrder(ContratoPlanningLine: Record "Contrato Planning Line"; ProdOrderLine: Record "Prod. Order Line"; ReservQty: Decimal; ReservQtyBase: Decimal)
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBindToProdOrder(ContratoPlanningLine, ProdOrderLine, ReservQty, ReservQtyBase, IsHandled);
        if IsHandled then
            exit;

        SetBinding(ReservationEntry.Binding::"Order-to-Order");
        TrackingSpecification.InitTrackingSpecification(
          DATABASE::"Prod. Order Line", ProdOrderLine.Status.AsInteger(), ProdOrderLine."Prod. Order No.", '', ProdOrderLine."Line No.", 0,
          ProdOrderLine."Variant Code", ProdOrderLine."Location Code", ProdOrderLine."Qty. per Unit of Measure");
        CreateReservationSetFrom(TrackingSpecification);
        CreateBindingReservation(ContratoPlanningLine, ProdOrderLine.Description, ProdOrderLine."Ending Date", ReservQty, ReservQtyBase);
    end;

    procedure BindToAssembly(ContratoPlanningLine: Record "Contrato Planning Line"; AssemblyHeader: Record "Assembly Header"; ReservQty: Decimal; ReservQtyBase: Decimal)
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
    begin
        SetBinding(ReservationEntry.Binding::"Order-to-Order");
        TrackingSpecification.InitTrackingSpecification(
          DATABASE::"Assembly Header", AssemblyHeader."Document Type".AsInteger(), AssemblyHeader."No.", '', 0, 0,
          AssemblyHeader."Variant Code", AssemblyHeader."Location Code", AssemblyHeader."Qty. per Unit of Measure");
        CreateReservationSetFrom(TrackingSpecification);
        CreateBindingReservation(ContratoPlanningLine, AssemblyHeader.Description, AssemblyHeader."Due Date", ReservQty, ReservQtyBase);
    end;

    [EventSubscriber(ObjectType::Page, PAGE::Reservation, 'OnGetQtyPerUOMFromSourceRecRef', '', false, false)]
    local procedure OnGetQtyPerUOMFromSourceRecRef(SourceRecRef: RecordRef; var QtyPerUOM: Decimal; var QtyReserved: Decimal; var QtyReservedBase: Decimal; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        if MatchThisTable(SourceRecRef.Number) then begin
            SourceRecRef.SetTable(ContratoPlanningLine);
            ContratoPlanningLine.Find();
            if ContratoPlanningLine.UpdatePlanned() then begin
                ContratoPlanningLine.Modify(true);
                Commit();
            end;
            QtyPerUOM := ContratoPlanningLine.GetReservationQty(QtyReserved, QtyReservedBase, QtyToReserve, QtyToReserveBase);
        end;
    end;

    local procedure SetReservSourceFor(SourceRecordRef: RecordRef; var ReservationEntry: Record "Reservation Entry"; var CaptionText: Text)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        SourceRecordRef.SetTable(ContratoPlanningLine);
        ContratoPlanningLine.TestField(Type, ContratoPlanningLine.Type::Item);
        ContratoPlanningLine.TestField("Planning Date");

        ContratoPlanningLine.SetReservationEntry(ReservationEntry);

        CaptionText := ContratoPlanningLine.GetSourceCaption();
    end;

    local procedure EntryStartNo(): Integer
    begin
        exit(Enum::"Reservation Summary Type"::"Job Planning Planned".AsInteger());
    end;

    local procedure MatchThisEntry(EntryNo: Integer): Boolean
    begin
        exit(EntryNo = Enum::"Reservation Summary Type"::"Job Planning Order".AsInteger());
    end;

    local procedure MatchThisTable(TableID: Integer): Boolean
    begin
        exit((TableID = database::"Contrato Planning Line") or (TableID = database::Contrato)); //for warehouse pick: DATABASE::Contrato
    end;

    [EventSubscriber(ObjectType::Page, Page::Reservation, 'OnSetReservSource', '', false, false)]
    local procedure OnSetReservSource(SourceRecRef: RecordRef; var ReservEntry: Record "Reservation Entry"; var CaptionText: Text)
    begin
        if MatchThisTable(SourceRecRef.Number) then
            SetReservSourceFor(SourceRecRef, ReservEntry, CaptionText);
    end;

    [EventSubscriber(ObjectType::Page, Page::Reservation, 'OnDrillDownTotalQuantity', '', false, false)]
    local procedure OnDrillDownTotalQuantity(SourceRecRef: RecordRef; ReservEntry: Record "Reservation Entry"; EntrySummary: Record "Entry Summary"; Location: Record Location; MaxQtyToReserve: Decimal)
    var
        AvailableContratoPlanningLines: page AvailableContratoPlanningLines;
    begin
        if MatchThisEntry(EntrySummary."Entry No.") then begin
            Clear(AvailableContratoPlanningLines);
            AvailableContratoPlanningLines.SetCurrentSubType(EntrySummary."Entry No." - EntryStartNo());
            AvailableContratoPlanningLines.SetSource(SourceRecRef, ReservEntry, ReservEntry.GetTransferDirection());
            AvailableContratoPlanningLines.RunModal();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Reservation, 'OnFilterReservEntry', '', false, false)]
    local procedure OnFilterReservEntry(var FilterReservEntry: Record "Reservation Entry"; ReservEntrySummary: Record "Entry Summary")
    begin
        if MatchThisEntry(ReservEntrySummary."Entry No.") then begin
            FilterReservEntry.SetRange("Source Type", DATABASE::"Contrato Planning Line");
            FilterReservEntry.SetRange("Source Subtype", ReservEntrySummary."Entry No." - EntryStartNo());
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Reservation, 'OnAfterRelatesToSummEntry', '', false, false)]
    local procedure OnRelatesToEntrySummary(var FilterReservEntry: Record "Reservation Entry"; FromEntrySummary: Record "Entry Summary"; var IsHandled: Boolean)
    begin
        if MatchThisEntry(FromEntrySummary."Entry No.") then
            IsHandled :=
                (FilterReservEntry."Source Type" = DATABASE::"Contrato Planning Line") and
                (FilterReservEntry."Source Subtype" = FromEntrySummary."Entry No." - EntryStartNo());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnCreateReservation', '', false, false)]
    local procedure OnCreateReservation(SourceRecRef: RecordRef; TrackingSpecification: Record "Tracking Specification"; ForReservEntry: Record "Reservation Entry"; Description: Text[100]; ExpectedDate: Date; Quantity: Decimal; QuantityBase: Decimal)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        if MatchThisTable(ForReservEntry."Source Type") then begin
            CreateReservationSetFrom(TrackingSpecification);
            SourceRecRef.SetTable(ContratoPlanningLine);
            CreateReservation(ContratoPlanningLine, Description, ExpectedDate, Quantity, QuantityBase, ForReservEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnLookupDocument', '', false, false)]
    local procedure OnLookupDocument(SourceType: Integer; SourceID: Code[20])
    var
        Contrato: Record Contrato;
    begin
        if MatchThisTable(SourceType) then begin
            Contrato.Reset();
            Contrato.SetRange("No.", SourceID);
            PAGE.RunModal(PAGE::"Contrato Card", Contrato)
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnLookupLine', '', false, false)]
    local procedure OnLookupLine(SourceType: Integer; SourceRefNo: Integer)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        if MatchThisTable(SourceType) then begin
            ContratoPlanningLine.Reset();
            ContratoPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
            ContratoPlanningLine.SetRange("Contrato Contract Entry No.", SourceRefNo);
            PAGE.Run(0, ContratoPlanningLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnFilterReservFor', '', false, false)]
    local procedure OnFilterReservFor(SourceRecRef: RecordRef; var ReservEntry: Record "Reservation Entry"; var CaptionText: Text)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        if MatchThisTable(SourceRecRef.Number) then begin
            SourceRecRef.SetTable(ContratoPlanningLine);
            ContratoPlanningLine.SetReservationFilters(ReservEntry);
            CaptionText := ContratoPlanningLine.GetSourceCaption();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnCalculateRemainingQty', '', false, false)]
    local procedure OnCalculateRemainingQty(SourceRecRef: RecordRef; var ReservEntry: Record "Reservation Entry"; var RemainingQty: Decimal; var RemainingQtyBase: Decimal)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        if MatchThisTable(ReservEntry."Source Type") then begin
            SourceRecRef.SetTable(ContratoPlanningLine);
            ContratoPlanningLine.GetRemainingQty(RemainingQty, RemainingQtyBase);
        end;
    end;

    local procedure GetSourceValue(ReservationEntry: Record "Reservation Entry"; var SourceRecordRef: RecordRef; ReturnOption: Option "Net Qty. (Base)","Gross Qty. (Base)"): Decimal
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
        ContratoPlanningLine.SetRange("Contrato Contract Entry No.", ReservationEntry."Source Ref. No.");
        ContratoPlanningLine.FindFirst();
        SourceRecordRef.GetTable(ContratoPlanningLine);
        case ReturnOption of
            ReturnOption::"Net Qty. (Base)":
                exit(ContratoPlanningLine."Remaining Qty. (Base)");
            ReturnOption::"Gross Qty. (Base)":
                exit(ContratoPlanningLine."Quantity (Base)");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnGetSourceRecordValue', '', false, false)]
    local procedure OnGetSourceRecordValue(var ReservEntry: Record "Reservation Entry"; ReturnOption: Option; var ReturnQty: Decimal; var SourceRecRef: RecordRef)
    begin
        if MatchThisTable(ReservEntry."Source Type") then
            ReturnQty := GetSourceValue(ReservEntry, SourceRecRef, ReturnOption);
    end;

    local procedure UpdateStatistics(ReservationEntry: Record "Reservation Entry"; var TempEntrySummary: Record "Entry Summary" temporary; AvailabilityDate: Date; LineType: Option; Positive: Boolean; var TotalQuantity: Decimal)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        AvailabilityFilter: Text;
    begin
        if not ContratoPlanningLine.ReadPermission then
            exit;

        AvailabilityFilter := ReservationEntry.GetAvailabilityFilter(AvailabilityDate, Positive);
        ContratoPlanningLine.FilterLinesForReservation(ReservationEntry, LineType, AvailabilityFilter, Positive);
        if ContratoPlanningLine.FindSet() then
            repeat
                ContratoPlanningLine.CalcFields("Reserved Qty. (Base)");
                TempEntrySummary."Total Reserved Quantity" -= ContratoPlanningLine."Reserved Qty. (Base)";
                TotalQuantity += ContratoPlanningLine."Remaining Qty. (Base)";
            until ContratoPlanningLine.Next() = 0;

        if TotalQuantity = 0 then
            exit;

        if (TotalQuantity < 0) = Positive then begin
            TempEntrySummary."Table ID" := DATABASE::"Contrato Planning Line";
            TempEntrySummary."Summary Type" :=
                CopyStr(StrSubstNo(SummaryTypeTxt, ContratoPlanningLine.TableCaption(), ContratoPlanningLine.Status), 1, MaxStrLen(TempEntrySummary."Summary Type"));
            TempEntrySummary."Total Quantity" := -TotalQuantity;
            TempEntrySummary."Total Available Quantity" := TempEntrySummary."Total Quantity" - TempEntrySummary."Total Reserved Quantity";
            if not TempEntrySummary.Insert() then
                TempEntrySummary.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnUpdateStatistics', '', false, false)]
    local procedure OnUpdateStatistics(CalcReservEntry: Record "Reservation Entry"; var ReservSummEntry: Record "Entry Summary"; AvailabilityDate: Date; Positive: Boolean; var TotalQuantity: Decimal)
    begin
        if MatchThisEntry(ReservSummEntry."Entry No.") then
            UpdateStatistics(
                CalcReservEntry, ReservSummEntry, AvailabilityDate, ReservSummEntry."Entry No." - 131, Positive, TotalQuantity);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Reservation Entries", 'OnLookupReserved', '', false, false)]
    local procedure OnLookupReserved(var ReservationEntry: Record "Reservation Entry")
    begin
        if MatchThisTable(ReservationEntry."Source Type") then
            ShowSourceLines(ReservationEntry);
    end;

    local procedure ShowSourceLines(var ReservationEntry: Record "Reservation Entry")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoPlanningLine.SetRange(Status, ReservationEntry."Source Subtype");
        ContratoPlanningLine.SetRange("Contrato No.", ReservationEntry."Source ID");
        ContratoPlanningLine.SetRange("Contrato Contract Entry No.", ReservationEntry."Source Ref. No.");
        PAGE.RunModal(Page::"Contrato Planning Lines", ContratoPlanningLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReservQuantity(ContratoPlanningLine: Record "Contrato Planning Line"; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckReservedQtyBase(ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; var QuantityBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyQuantity(var NewContratoPlanningLine: Record "Contrato Planning Line"; var OldContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifyChangeOnBeforeHasErrorCheck(NewContratoPlanningLine: Record "Contrato Planning Line"; OldContratoPlanningLine: Record "Contrato Planning Line"; var HasError: Boolean; var ShowError: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBindToProdOrder(ContratoPlanningLine: Record "Contrato Planning Line"; ProdOrderLine: Record "Prod. Order Line"; ReservQty: Decimal; ReservQtyBase: Decimal; var IsHandled: Boolean)
    begin
    end;
}

