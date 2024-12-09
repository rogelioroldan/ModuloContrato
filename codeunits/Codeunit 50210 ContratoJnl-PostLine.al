codeunit 50210 "Contrato Jnl.-Post Line"
{
    Permissions = TableData "Contrato Ledger Entry" = rimd,
                  TableData "Contrato Register" = rimd,
                  TableData Contrato = rimd,
                  TableData "Value Entry" = rimd;
    TableNo = "Contrato Journal Line";

    trigger OnRun()
    begin
        GetGLSetup();
        RunWithCheck(Rec);
    end;

    var
        Cust: Record Customer;
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoJnlLine2: Record "Contrato Journal Line";
        ItemJnlLine: Record "Item Journal Line";
        ContratoReg: Record "Contrato Register";
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        Location: Record Location;
        Item: Record Item;
        ContratoJnlCheckLine: Codeunit "Contrato Jnl.-Check Line";
        ResJnlPostLine: Codeunit "Res. Jnl.-Post Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        ContratoPostLine: Codeunit "Contrato Post-Line";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        AsmPost: Codeunit "Assembly-Post";
        GLSetupRead: Boolean;
        CalledFromInvtPutawayPick: Boolean;
        NextEntryNo: Integer;
        GLEntryNo: Integer;
        AssemblyPostProgressMsg: Label '#1#################################\\Posting Assembly #2###########', Comment = '%1 = Text, %2 = Progress bar';
        Format4Lbl: Label '%1 %2 %3 %4', Comment = '%1 = Contrato No., %2 = Contrato Task No., %3 = Contrato Planning Line No., %4 = Line No.';
        Format2Lbl: Label '%1 %2', Comment = 'Assemble %1 = Document Type, %2 = No.';

    procedure RunWithCheck(var ContratoJnlLine2: Record "Contrato Journal Line"): Integer
    var
        ContratoLedgEntryNo: Integer;
    begin
        OnBeforeRunWithCheck(ContratoJnlLine2);

        ContratoJnlLine.Copy(ContratoJnlLine2);
        ContratoLedgEntryNo := Code(true);
        ContratoJnlLine2 := ContratoJnlLine;
        exit(ContratoLedgEntryNo);
    end;

    local procedure "Code"(CheckLine: Boolean): Integer
    var
        ContratoLedgEntryNo: Integer;
        ShouldPostUsage: Boolean;
    begin
        OnBeforeCode(ContratoJnlLine);

        GetGLSetup();

        if ContratoJnlLine.EmptyLine() then
            exit;

        OnCodeOnBeforeCheckLine(ContratoJnlLine, CalledFromInvtPutawayPick, CheckLine);
        if CheckLine then begin
            ContratoJnlCheckLine.SetCalledFromInvtPutawayPick(CalledFromInvtPutawayPick);
            ContratoJnlCheckLine.RunCheck(ContratoJnlLine);
        end;

        GetNextEntryNo();

        if ContratoJnlLine."Document Date" = 0D then
            ContratoJnlLine."Document Date" := ContratoJnlLine."Posting Date";

        OnBeforeCreateContratoRegister(ContratoJnlLine);
        if ContratoReg."No." = 0 then begin
            ContratoReg.LockTable();
            if (not ContratoReg.FindLast()) or (ContratoReg."To Entry No." <> 0) then
                InsertContratoRegister();
        end;

        GetAndCheckContrato();

        ContratoJnlLine2 := ContratoJnlLine;

        OnAfterCopyContratoJnlLine(ContratoJnlLine, ContratoJnlLine2);

        ContratoJnlLine2."Source Currency Total Cost" := 0;
        ContratoJnlLine2."Source Currency Total Price" := 0;
        ContratoJnlLine2."Source Currency Line Amount" := 0;

        GetGLSetup();
        if (GLSetup."Additional Reporting Currency" <> '') and
            (ContratoJnlLine2."Source Currency Code" <> GLSetup."Additional Reporting Currency")
        then
            UpdateContratoJnlLineSourceCurrencyAmounts(ContratoJnlLine2);

        PostATO(ContratoJnlLine2);

        ShouldPostUsage := ContratoJnlLine2."Entry Type" = ContratoJnlLine2."Entry Type"::Usage;
        OnCodeOnAfterCalcShouldPostUsage(ContratoJnlLine2, ShouldPostUsage, ContratoLedgEntryNo);
        if ShouldPostUsage then
            case ContratoJnlLine.Type of
                ContratoJnlLine.Type::Resource:
                    ContratoLedgEntryNo := PostResource(ContratoJnlLine2);
                ContratoJnlLine.Type::Item:
                    ContratoLedgEntryNo := PostItem(ContratoJnlLine);
                ContratoJnlLine.Type::"G/L Account":
                    ContratoLedgEntryNo := CreateContratoLedgEntry(ContratoJnlLine2);
            end
        else
            ContratoLedgEntryNo := CreateContratoLedgEntry(ContratoJnlLine2);

        OnAfterRunCode(ContratoJnlLine2, ContratoLedgEntryNo, ContratoReg, NextEntryNo);

        exit(ContratoLedgEntryNo);
    end;

    local procedure GetNextEntryNo()
    var
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetNextEntryNo(ContratoJnlLine, NextEntryNo, IsHandled, ContratoLedgerEntry);
        if not IsHandled then
            if ContratoLedgerEntry."Entry No." = 0 then begin
                ContratoLedgerEntry.LockTable();
                NextEntryNo := ContratoLedgerEntry.GetLastEntryNo() + 1;
            end;
        OnAfterGetNextEntryNo(ContratoLedgerEntry, NextEntryNo);
    end;

    local procedure InsertContratoRegister()
    begin
        ContratoReg.Init();
        ContratoReg."No." := ContratoReg."No." + 1;
        ContratoReg."From Entry No." := NextEntryNo;
        ContratoReg."To Entry No." := NextEntryNo;
        ContratoReg."Creation Date" := Today;
        ContratoReg."Creation Time" := Time;
        ContratoReg."Source Code" := ContratoJnlLine."Source Code";
        ContratoReg."Journal Batch Name" := ContratoJnlLine."Journal Batch Name";
        ContratoReg."User ID" := CopyStr(UserId(), 1, MaxStrLen(ContratoReg."User ID"));
        OnIsertContratoRegisterOnBeforeInsert(ContratoJnlLine, ContratoReg);
        ContratoReg.Insert();
    end;

    local procedure GetAndCheckContrato()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetAndCheckContrato(ContratoJnlLine, IsHandled);
        if IsHandled then
            exit;

        Contrato.Get(ContratoJnlLine."Contrato No.");
        CheckContrato(ContratoJnlLine, Contrato);
    end;

    internal procedure SetCalledFromInvtPutawayPick(NewCalledFromInvtPutawayPick: Boolean)
    begin
        CalledFromInvtPutawayPick := NewCalledFromInvtPutawayPick;
    end;

    local procedure CheckContrato(var ContratoJnlLine: Record "Contrato Journal Line"; Contrato: Record Contrato)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckContrato(ContratoJnlLine, Contrato, IsHandled, ContratoReg, NextEntryNo);
        if IsHandled then
            exit;

        Contrato.TestBlocked();
        Contrato.TestField("Bill-to Customer No.");
        Cust.Get(Contrato."Bill-to Customer No.");
        ContratoJnlLine.TestField("Currency Code", Contrato."Currency Code");
        IsHandled := false;
        OnCheckContratoOnBeforeTestContratoTaskType(ContratoJnlLine, IsHandled);
        if not IsHandled then begin
            ContratoTask.Get(ContratoJnlLine."Contrato No.", ContratoJnlLine."Contrato Task No.");
            ContratoTask.TestField("Contrato Task Type", ContratoTask."Contrato Task Type"::Posting);
        end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get();
        GLSetupRead := true;
    end;

    procedure CreateContratoLedgEntry(ContratoJnlLine2: Record "Contrato Journal Line"): Integer
    var
        ResLedgEntry: Record "Res. Ledger Entry";
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoPlanningLine: Record "Contrato Planning Line";
        Contrato: Record Contrato;
        ContratoTransferLine: Codeunit "Contrato Transfer Line";
        ContratoLinkUsage: Codeunit "Contrato Link Usage";
        ContratoLedgEntryNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateContratoLedgEntry(ContratoJnlLine2, IsHandled, ContratoLedgEntryNo);
        if IsHandled then
            exit(ContratoLedgEntryNo);

        SetCurrency(ContratoJnlLine2);

        ContratoLedgEntry.Init();
        ContratoTransferLine.FromJnlLineToLedgEntry(ContratoJnlLine2, ContratoLedgEntry);

        IsHandled := false;
        OnCreateContratoLedgEntryOnBeforeAssignQtyCostPrice(ContratoLedgEntry, ContratoJnlLine2, IsHandled);
        if not IsHandled then
            if ContratoLedgEntry."Entry Type" = ContratoLedgEntry."Entry Type"::Sale then begin
                ContratoLedgEntry.Quantity := -ContratoJnlLine2.Quantity;
                ContratoLedgEntry."Quantity (Base)" := -ContratoJnlLine2."Quantity (Base)";
                ContratoLedgEntry."Total Cost (LCY)" := -ContratoJnlLine2."Total Cost (LCY)";
                ContratoLedgEntry."Total Cost" := -ContratoJnlLine2."Total Cost";
                ContratoLedgEntry."Total Price (LCY)" := -ContratoJnlLine2."Total Price (LCY)";
                ContratoLedgEntry."Total Price" := -ContratoJnlLine2."Total Price";
                ContratoLedgEntry."Line Amount (LCY)" := -ContratoJnlLine2."Line Amount (LCY)";
                ContratoLedgEntry."Line Amount" := -ContratoJnlLine2."Line Amount";
                ContratoLedgEntry."Line Discount Amount (LCY)" := -ContratoJnlLine2."Line Discount Amount (LCY)";
                ContratoLedgEntry."Line Discount Amount" := -ContratoJnlLine2."Line Discount Amount";
            end else begin
                ContratoLedgEntry.Quantity := ContratoJnlLine2.Quantity;
                ContratoLedgEntry."Quantity (Base)" := ContratoJnlLine2."Quantity (Base)";
                ContratoLedgEntry."Total Cost (LCY)" := ContratoJnlLine2."Total Cost (LCY)";
                ContratoLedgEntry."Total Cost" := ContratoJnlLine2."Total Cost";
                ContratoLedgEntry."Total Price (LCY)" := ContratoJnlLine2."Total Price (LCY)";
                ContratoLedgEntry."Total Price" := ContratoJnlLine2."Total Price";
                ContratoLedgEntry."Line Amount (LCY)" := ContratoJnlLine2."Line Amount (LCY)";
                ContratoLedgEntry."Line Amount" := ContratoJnlLine2."Line Amount";
                ContratoLedgEntry."Line Discount Amount (LCY)" := ContratoJnlLine2."Line Discount Amount (LCY)";
                ContratoLedgEntry."Line Discount Amount" := ContratoJnlLine2."Line Discount Amount";
            end;

        ContratoLedgEntry."Additional-Currency Total Cost" := -ContratoLedgEntry."Additional-Currency Total Cost";
        ContratoLedgEntry."Add.-Currency Total Price" := -ContratoLedgEntry."Add.-Currency Total Price";
        ContratoLedgEntry."Add.-Currency Line Amount" := -ContratoLedgEntry."Add.-Currency Line Amount";

        ContratoLedgEntry."Entry No." := NextEntryNo;
        ContratoLedgEntry."No. Series" := ContratoJnlLine2."Posting No. Series";
        ContratoLedgEntry."Original Unit Cost (LCY)" := ContratoLedgEntry."Unit Cost (LCY)";
        ContratoLedgEntry."Original Total Cost (LCY)" := ContratoLedgEntry."Total Cost (LCY)";
        ContratoLedgEntry."Original Unit Cost" := ContratoLedgEntry."Unit Cost";
        ContratoLedgEntry."Original Total Cost" := ContratoLedgEntry."Total Cost";
        ContratoLedgEntry."Original Total Cost (ACY)" := ContratoLedgEntry."Additional-Currency Total Cost";
        ContratoLedgEntry."Dimension Set ID" := ContratoJnlLine2."Dimension Set ID";

        case ContratoJnlLine2.Type of
            ContratoJnlLine2.Type::Resource:
                if ContratoJnlLine2."Entry Type" = ContratoJnlLine2."Entry Type"::Usage then
                    if ResLedgEntry.FindLast() then begin
                        ContratoLedgEntry."Ledger Entry Type" := ContratoLedgEntry."Ledger Entry Type"::Resource;
                        ContratoLedgEntry."Ledger Entry No." := ResLedgEntry."Entry No.";
                    end;
            ContratoJnlLine2.Type::Item:
                begin
                    ContratoLedgEntry."Ledger Entry Type" := ContratoJnlLine2."Ledger Entry Type"::Item;
                    ContratoLedgEntry."Ledger Entry No." := ContratoJnlLine2."Ledger Entry No.";
                    ContratoLedgEntry.CopyTrackingFromContratoJnlLine(ContratoJnlLine2);
                end;
            ContratoJnlLine2.Type::"G/L Account":
                begin
                    ContratoLedgEntry."Ledger Entry Type" := ContratoLedgEntry."Ledger Entry Type"::" ";
                    if GLEntryNo > 0 then begin
                        ContratoLedgEntry."Ledger Entry Type" := ContratoLedgEntry."Ledger Entry Type"::"G/L Account";
                        ContratoLedgEntry."Ledger Entry No." := GLEntryNo;
                        GLEntryNo := 0;
                    end;
                end;
        end;

        OnCreateContratoLedgerEntryOnAfterAssignLedgerEntryTypeAndNo(ContratoLedgEntry, ContratoJnlLine2, GLEntryNo);

        if ContratoLedgEntry."Entry Type" = ContratoLedgEntry."Entry Type"::Sale then
            ContratoLedgEntry.CopyTrackingFromContratoJnlLine(ContratoJnlLine2);

        OnBeforeContratoLedgEntryInsert(ContratoLedgEntry, ContratoJnlLine2);
        ContratoLedgEntry.Insert(true);
        OnAfterContratoLedgEntryInsert(ContratoLedgEntry, ContratoJnlLine2);

        ContratoReg."To Entry No." := NextEntryNo;
        ContratoReg.Modify();

        ContratoLedgEntryNo := ContratoLedgEntry."Entry No.";
        IsHandled := false;
        OnBeforeApplyUsageLink(ContratoLedgEntry, ContratoJnlLine2, IsHandled);
        if not IsHandled then
            if ContratoLedgEntry."Entry Type" = ContratoLedgEntry."Entry Type"::Usage then begin
                // Usage Link should be applied if it is enabled for the Contrato,
                // if a Contrato Planning Line number is defined or if it is enabled for a Contrato Planning Line.
                Contrato.Get(ContratoLedgEntry."Contrato No.");
                if Contrato."Apply Usage Link" or
                   (ContratoJnlLine2."Contrato Planning Line No." <> 0) or
                   ContratoLinkUsage.FindMatchingContratoPlanningLine(ContratoPlanningLine, ContratoLedgEntry)
                then
                    ContratoLinkUsage.ApplyUsage(ContratoLedgEntry, ContratoJnlLine2, CalledFromInvtPutawayPick)
                else
                    ContratoPostLine.InsertPlLineFromLedgEntry(ContratoLedgEntry)
            end;

        NextEntryNo := NextEntryNo + 1;
        OnAfterApplyUsageLink(ContratoLedgEntry);

        exit(ContratoLedgEntryNo);
    end;

    local procedure CreateContratoLedgEntryFromPostItem(ContratoJournalLine: Record "Contrato Journal Line"; ValueEntry: Record "Value Entry"): Integer
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateContratoLedgEntryFromPostItem(ContratoJournalLine, ValueEntry, IsHandled);
        if IsHandled then
            exit(0);

        exit(CreateContratoLedgEntry(ContratoJournalLine))
    end;

    local procedure SetCurrency(ContratoJnlLine: Record "Contrato Journal Line")
    begin
        if ContratoJnlLine."Currency Code" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision()
        end else begin
            Currency.Get(ContratoJnlLine."Currency Code");
            Currency.TestField("Amount Rounding Precision");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
    end;

    local procedure PostItem(var ContratoJnlLine: Record "Contrato Journal Line") ContratoLedgEntryNo: Integer
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ContratoLedgEntry2: Record "Contrato Ledger Entry";
        ContratoPlanningLine: Record "Contrato Planning Line";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemJnlLine2: Record "Item Journal Line";
        ContratoJnlLineReserve: Codeunit "Contrato Jnl. Line-Reserve";
        SkipContratoLedgerEntry: Boolean;
        ApplyToContratoContractEntryNo: Boolean;
        TempRemainingQty: Decimal;
        RemainingAmount: Decimal;
        RemainingAmountLCY: Decimal;
        RemainingQtyToTrack: Decimal;
        IsHandled: Boolean;
    begin
        if not ContratoJnlLine."Contrato Posting Only" then begin
            IsHandled := false;
            OnBeforeItemPosting(ContratoJnlLine2, NextEntryNo, IsHandled);
            if not IsHandled then begin
                InitItemJnlLine();

                //Do not transfer remaining quantity when posting from Inventory Pick as the entry is created during posting process of Item through Item Jnl Line.
                ContratoJnlLineReserve.TransContratoJnlLineToItemJnlLine(ContratoJnlLine2, ItemJnlLine, ItemJnlLine."Quantity (Base)", CalledFromInvtPutawayPick);

                ApplyToContratoContractEntryNo := false;
                if ContratoPlanningLine.Get(ContratoJnlLine."Contrato No.", ContratoJnlLine."Contrato Task No.", ContratoJnlLine."Contrato Planning Line No.") then
                    ApplyToContratoContractEntryNo := true
                else
                    if ContratoPlanningReservationExists(ContratoJnlLine2."No.", ContratoJnlLine2."Contrato No.") then
                        if ApplyToMatchingContratoPlanningLine(ContratoJnlLine2, ContratoPlanningLine) then
                            ApplyToContratoContractEntryNo := true;

                if ApplyToContratoContractEntryNo then
                    ItemJnlLine."Job Contract Entry No." := ContratoPlanningLine."Contrato Contract Entry No.";

                OnPostItemOnBeforeAssignItemJnlLine(ContratoJnlLine, ContratoJnlLine2, ItemJnlLine, ContratoPlanningLine);

                ItemLedgEntry.LockTable();
                ItemJnlLine2 := ItemJnlLine;
                ItemJnlPostLine.RunWithCheck(ItemJnlLine);
                ItemJnlPostLine.CollectTrackingSpecification(TempTrackingSpecification);

                if ContratoJnlLine.IsInventoriableItem() then begin
                    PostWhseJnlLine(ItemJnlLine2, ItemJnlLine2.Quantity, ItemJnlLine2."Quantity (Base)", TempTrackingSpecification);
                    OnPostItemOnAfterPostWhseJnlLine(ContratoJnlLine2, ItemJnlPostLine);
                end;
            end;
        end;

        OnPostItemOnBeforeGetContratoConsumptionValueEntry(ContratoJnlLine);
        if GetContratoConsumptionValueEntry(ValueEntry, ContratoJnlLine) then begin
            RemainingAmount := ContratoJnlLine2."Line Amount";
            RemainingAmountLCY := ContratoJnlLine2."Line Amount (LCY)";
            RemainingQtyToTrack := ContratoJnlLine2.Quantity;
            repeat
                SkipContratoLedgerEntry := false;
                if ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                    ContratoLedgEntry2.SetRange("Ledger Entry Type", ContratoLedgEntry2."Ledger Entry Type"::Item);
                    ContratoLedgEntry2.SetRange("Ledger Entry No.", ItemLedgEntry."Entry No.");
                    // The following code is only to secure that JLEs created at receipt in version 6.0 or earlier,
                    // are not created again at point of invoice (6.0 SP1 and newer).
                    if ContratoLedgEntry2.FindFirst() and (ContratoLedgEntry2.Quantity = -ItemLedgEntry.Quantity) then
                        SkipContratoLedgerEntry := true
                    else begin
                        ContratoJnlLine2.CopyTrackingFromItemLedgEntry(ItemLedgEntry);
                        OnPostItemOnAfterApplyItemTracking(ContratoJnlLine2, ItemLedgEntry, ContratoLedgEntry2, SkipContratoLedgerEntry);
                    end;
                end;
                OnPostItemOnAfterSetSkipContratoLedgerEntry(ContratoJnlLine2, ItemLedgEntry, SkipContratoLedgerEntry);
                if not SkipContratoLedgerEntry then begin
                    TempRemainingQty := ContratoJnlLine2."Remaining Qty.";
                    ContratoJnlLine2.Quantity := -ValueEntry."Invoiced Quantity" / ContratoJnlLine."Qty. per Unit of Measure";
                    ContratoJnlLine2."Quantity (Base)" :=
                        Round(ContratoJnlLine2.Quantity * ContratoJnlLine."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision());
                    Currency.Initialize(ContratoJnlLine."Currency Code");

                    OnPostItemOnBeforeUpdateTotalAmounts(ContratoJnlLine2, ItemLedgEntry, ValueEntry);

                    UpdateContratoJnlLineTotalAmounts(ContratoJnlLine2, Currency."Amount Rounding Precision");
                    UpdateContratoJnlLineAmount(
                        ContratoJnlLine2, RemainingAmount, RemainingAmountLCY, RemainingQtyToTrack, Currency."Amount Rounding Precision");

                    ContratoJnlLine2.Validate("Remaining Qty.", TempRemainingQty);
                    ContratoJnlLine2."Ledger Entry Type" := ContratoJnlLine."Ledger Entry Type"::Item;
                    ContratoJnlLine2."Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
                    ContratoLedgEntryNo := CreateContratoLedgEntryFromPostItem(ContratoJnlLine2, ValueEntry);
                    ValueEntry."Job Ledger Entry No." := ContratoLedgEntryNo;
                    ModifyValueEntry(ValueEntry);
                end;
            until ValueEntry.Next() = 0;
        end;

        OnAfterPostItem(ContratoJnlLine2, ItemJnlPostLine);
    end;

    local procedure ModifyValueEntry(var ValueEntry: Record "Value Entry")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeModifyValueEntry(ValueEntry, ContratoJnlLine2, IsHandled);
        if IsHandled then
            exit;

        ValueEntry.Modify(true);
    end;

    local procedure PostResource(var ContratoJnlLine2: Record "Contrato Journal Line") EntryNo: Integer
    var
        ResJnlLine: Record "Res. Journal Line";
        ResLedgEntry: Record "Res. Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostResource(ContratoJnlLine, ContratoJnlLine2, EntryNo, IsHandled);
        if IsHandled then
            exit(EntryNo);

        ResJnlLine.Init();
        //ResJnlLine.CopyFromContratoJnlLine(ContratoJnlLine2);
        ResLedgEntry.LockTable();
        ResJnlPostLine.RunWithCheck(ResJnlLine);
        UpdateContratoJnlLineResourceGroupNo(ContratoJnlLine2, ResJnlLine);
        exit(CreateContratoLedgEntry(ContratoJnlLine2));
    end;

    local procedure UpdateContratoJnlLineResourceGroupNo(var ContratoJnlLine2: Record "Contrato Journal Line"; ResJnlLine: Record "Res. Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateContratoJnlLineResourceGroupNo(ContratoJnlLine2, ResJnlLine, IsHandled);
        if IsHandled then
            exit;

        ContratoJnlLine2."Resource Group No." := ResJnlLine."Resource Group No.";
    end;

    local procedure PostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
        TempWarehouseJournalLine: Record "Warehouse Journal Line" temporary;
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        WMSManagement: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostWhseJnlLine(ItemJnlLine, OriginalQuantity, OriginalQuantityBase, TempTrackingSpecification, IsHandled);
        if IsHandled then
            exit;

        if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Consumption, ItemJnlLine."Entry Type"::Output] then
            exit;

        ItemJnlLine.Quantity := OriginalQuantity;
        ItemJnlLine."Quantity (Base)" := OriginalQuantityBase;
        GetLocation(ItemJnlLine."Location Code");
        if Location."Bin Mandatory" then
            if WMSManagement.CreateWhseJnlLine(ItemJnlLine, 0, WarehouseJournalLine, false) then begin
                SetWhseDocForPicks(WarehouseJournalLine, Location.Code);
                TempTrackingSpecification.ModifyAll("Source Type", DATABASE::"Contrato Journal Line");
                ItemTrackingManagement.SplitWhseJnlLine(WarehouseJournalLine, TempWarehouseJournalLine, TempTrackingSpecification, false);
                if TempWarehouseJournalLine.Find('-') then
                    repeat
                        WMSManagement.CheckWhseJnlLine(TempWarehouseJournalLine, 1, 0, false);
                        WhseJnlRegisterLine.RegisterWhseJnlLine(TempWarehouseJournalLine);
                    until TempWarehouseJournalLine.Next() = 0;
            end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    procedure SetGLEntryNo(GLEntryNo2: Integer)
    begin
        GLEntryNo := GLEntryNo2;
    end;

    local procedure InitItemJnlLine()
    begin
        ItemJnlLine.Init();
        //ItemJnlLine.CopyFromContratoJnlLine(ContratoJnlLine2);
        ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Customer;
        ItemJnlLine."Source No." := Contrato."Bill-to Customer No.";
        Item.Get(ContratoJnlLine2."No.");
        ItemJnlLine."Inventory Posting Group" := Item."Inventory Posting Group";
        ItemJnlLine."Item Category Code" := Item."Item Category Code";
    end;

    local procedure UpdateContratoJnlLineTotalAmounts(var ContratoJnlLineToUpdate: Record "Contrato Journal Line"; AmtRoundingPrecision: Decimal)
    begin
        ContratoJnlLineToUpdate."Total Cost" := Round(ContratoJnlLineToUpdate."Unit Cost" * ContratoJnlLineToUpdate.Quantity, AmtRoundingPrecision);
        ContratoJnlLineToUpdate."Total Cost (LCY)" := Round(ContratoJnlLineToUpdate."Unit Cost (LCY)" * ContratoJnlLineToUpdate.Quantity, GLSetup."Amount Rounding Precision");
        ContratoJnlLineToUpdate."Total Price" := Round(ContratoJnlLineToUpdate."Unit Price" * ContratoJnlLineToUpdate.Quantity, AmtRoundingPrecision);
        ContratoJnlLineToUpdate."Total Price (LCY)" := Round(ContratoJnlLineToUpdate."Unit Price (LCY)" * ContratoJnlLineToUpdate.Quantity, GLSetup."Amount Rounding Precision");
        OnAfterUpdateContratoJnlLineTotalAmounts(ContratoJnlLineToUpdate, AmtRoundingPrecision, GLSetup."Amount Rounding Precision");
    end;

    local procedure UpdateContratoJnlLineAmount(var ContratoJnlLineToUpdate: Record "Contrato Journal Line"; var RemainingAmount: Decimal; var RemainingAmountLCY: Decimal; var RemainingQtyToTrack: Decimal; AmtRoundingPrecision: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateContratoJnlLineAmount(ContratoJnlLineToUpdate, RemainingAmount, RemainingAmountLCY, RemainingQtyToTrack, AmtRoundingPrecision, IsHandled);
        if IsHandled then
            exit;

        ContratoJnlLineToUpdate."Line Amount" := Round(RemainingAmount * ContratoJnlLineToUpdate.Quantity / RemainingQtyToTrack, AmtRoundingPrecision);
        ContratoJnlLineToUpdate."Line Amount (LCY)" := Round(RemainingAmountLCY * ContratoJnlLineToUpdate.Quantity / RemainingQtyToTrack, AmtRoundingPrecision);

        RemainingAmount -= ContratoJnlLineToUpdate."Line Amount";
        RemainingAmountLCY -= ContratoJnlLineToUpdate."Line Amount (LCY)";
        RemainingQtyToTrack -= ContratoJnlLineToUpdate.Quantity;
    end;

    local procedure UpdateContratoJnlLineSourceCurrencyAmounts(var ContratoJnlLine: Record "Contrato Journal Line")
    begin
        Currency.Get(GLSetup."Additional Reporting Currency");
        Currency.TestField("Amount Rounding Precision");
        ContratoJnlLine."Source Currency Total Cost" :=
            Round(
            CurrExchRate.ExchangeAmtLCYToFCY(
                ContratoJnlLine."Posting Date",
                GLSetup."Additional Reporting Currency", ContratoJnlLine."Total Cost (LCY)",
                CurrExchRate.ExchangeRate(
                ContratoJnlLine."Posting Date", GLSetup."Additional Reporting Currency")),
            Currency."Amount Rounding Precision");
        ContratoJnlLine."Source Currency Total Price" :=
            Round(
            CurrExchRate.ExchangeAmtLCYToFCY(
                ContratoJnlLine."Posting Date",
                GLSetup."Additional Reporting Currency", ContratoJnlLine."Total Price (LCY)",
                CurrExchRate.ExchangeRate(
                ContratoJnlLine."Posting Date", GLSetup."Additional Reporting Currency")),
            Currency."Amount Rounding Precision");
        ContratoJnlLine."Source Currency Line Amount" :=
            Round(
            CurrExchRate.ExchangeAmtLCYToFCY(
                ContratoJnlLine."Posting Date",
                GLSetup."Additional Reporting Currency", ContratoJnlLine."Line Amount (LCY)",
                CurrExchRate.ExchangeRate(
                ContratoJnlLine."Posting Date", GLSetup."Additional Reporting Currency")),
            Currency."Amount Rounding Precision");
    end;

    local procedure ContratoPlanningReservationExists(ItemNo: Code[20]; ContratoNo: Code[20]) Result: Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeContratoPlanningReservationExists(ItemNo, ContratoNo, Result, IsHandled);
        if IsHandled then
            exit(Result);

        ReservationEntry.SetRange("Item No.", ItemNo);
        ReservationEntry.SetRange("Source Type", DATABASE::"Contrato Planning Line");
        ReservationEntry.SetRange("Source Subtype", Contrato.Status::Open);
        ReservationEntry.SetRange("Source ID", ContratoNo);
        Result := not ReservationEntry.IsEmpty();
    end;

    local procedure GetContratoConsumptionValueEntry(var ValueEntry: Record "Value Entry"; ContratoJournalLine: Record "Contrato Journal Line") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetContratoConsumptionValueEntry(ContratoJournalLine, Result, IsHandled, ValueEntry);
        if IsHandled then
            exit(Result);

        ValueEntry.SetCurrentKey("Job No.", "Job Task No.", "Document No.");
        ValueEntry.SetRange("Item No.", ContratoJournalLine."No.");
        ValueEntry.SetRange("Job No.", ContratoJournalLine."Contrato No.");
        ValueEntry.SetRange("Job Task No.", ContratoJournalLine."Contrato Task No.");
        ValueEntry.SetRange("Document No.", ContratoJournalLine."Document No.");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Negative Adjmt.");
        ValueEntry.SetRange("Job Ledger Entry No.", 0);
        OnGetContratoConsumptionValueEntryFilter(ValueEntry, ContratoJnlLine, ContratoJournalLine);

        exit(ValueEntry.FindSet());
    end;

    local procedure ApplyToMatchingContratoPlanningLine(var ContratoJnlLine: Record "Contrato Journal Line"; var ContratoPlanningLine: Record "Contrato Planning Line"): Boolean
    var
        Contrato: Record Contrato;
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoTransferLine: Codeunit "Contrato Transfer Line";
        ContratoLinkUsage: Codeunit "Contrato Link Usage";
    begin
        if ContratoLedgEntry."Entry Type" <> ContratoLedgEntry."Entry Type"::Usage then
            exit(false);

        Contrato.Get(ContratoJnlLine."Contrato No.");
        ContratoLedgEntry.Init();
        ContratoTransferLine.FromJnlLineToLedgEntry(ContratoJnlLine, ContratoLedgEntry);
        ContratoLedgEntry.Quantity := ContratoJnlLine.Quantity;
        ContratoLedgEntry."Quantity (Base)" := ContratoJnlLine."Quantity (Base)";

        if ContratoLinkUsage.FindMatchingContratoPlanningLine(ContratoPlanningLine, ContratoLedgEntry) then begin
            ContratoJnlLine.Validate("Contrato Planning Line No.", ContratoPlanningLine."Line No.");
            ContratoJnlLine.Modify(true);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SetWhseDocForPicks(var WarehouseJournalLine: Record "Warehouse Journal Line"; LocationCode: Code[10])
    var
        WhseLocation: Record Location;
        RequireWhseHandling: Boolean;
    begin
        if LocationCode = '' then
            RequireWhseHandling := WhseLocation.RequirePicking(LocationCode)
        else
            RequireWhseHandling := WhseLocation.Get(LocationCode) and (WhseLocation."Job Consump. Whse. Handling" <> Enum::"Job Consump. Whse. Handling"::"No Warehouse Handling");

        if RequireWhseHandling then
            WarehouseJournalLine.SetWhseDocument(WarehouseJournalLine."Whse. Document Type"::Job, ItemJnlLine."Job No.", ItemJnlLine."Job Contract Entry No.");
    end;

    local procedure PostATO(ContratoJournalLine: Record "Contrato Journal Line")
    var
        AsmHeader: Record "Assembly Header";
        ATOLink: Record "Assemble-to-OrderLinkContrato";
        ContratoPlanningLine: Record "Contrato Planning Line";
        Window: Dialog;
    begin
        if not ContratoJournalLine."Assemble to Order" then
            exit;

        if not ContratoPlanningLine.Get(ContratoJournalLine."Contrato No.", ContratoJournalLine."Contrato Task No.", ContratoJournalLine."Contrato Planning Line No.") then
            exit;

        if ContratoPlanningLine.AsmToOrderExists(AsmHeader) then begin
            Window.Open(AssemblyPostProgressMsg);
            Window.Update(1,
                StrSubstNo(Format4Lbl,
                ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine.FieldCaption("Line No."), ContratoPlanningLine."Line No."));
            Window.Update(2, StrSubstNo(Format2Lbl, AsmHeader."Document Type", AsmHeader."No."));

            ContratoPlanningLine.CheckAsmToOrder(AsmHeader);
            if not HasQtyToAsm(ContratoPlanningLine, AsmHeader) then
                exit;
            if AsmHeader."Remaining Quantity (Base)" = 0 then
                exit;

            if ContratoJournalLine."Quantity (Base)" < AsmHeader."Remaining Quantity (Base)" then begin
                AsmHeader.Validate("Quantity to Assemble", ContratoJournalLine.Quantity);
                AsmHeader.Modify(true);
            end;

            AsmPost.SetPostingDate(true, ContratoJournalLine."Posting Date");
            AsmPost.InitPostATO(AsmHeader);
            CreatePosterATOLink(AsmHeader, ContratoPlanningLine);
            AsmPost.PostATO(AsmHeader, ItemJnlPostLine, ResJnlPostLine, WhseJnlPostLine);
            if AsmHeader."Remaining Quantity (Base)" = 0 then begin
                AsmPost.FinalizePostATO(AsmHeader);
                ATOLink.Get(AsmHeader."Document Type", AsmHeader."No.");
                ATOLink.Delete();
            end;

            Window.Close();
        end;
    end;

    local procedure CreatePosterATOLink(var AsmHeader: Record "Assembly Header"; var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        PostedATOLink: Record "Posted Assemble-to-Order Link";
    begin
        PostedATOLink.Init();
        PostedATOLink."Assembly Document Type" := PostedATOLink."Assembly Document Type"::Assembly;
        PostedATOLink."Assembly Document No." := AsmHeader."Posting No.";
        PostedATOLink."Document Type" := PostedATOLink."Document Type"::" ";
        PostedATOLink."Document Line No." := ContratoPlanningLine."Line No.";
        PostedATOLink."Assembly Order No." := AsmHeader."No.";
        PostedATOLink."Job No." := ContratoPlanningLine."Contrato No.";
        PostedATOLink."Job Task No." := ContratoPlanningLine."Contrato Task No.";
        PostedATOLink."Assembled Quantity" := AsmHeader."Quantity to Assemble";
        PostedATOLink."Assembled Quantity (Base)" := AsmHeader."Quantity to Assemble (Base)";
        PostedATOLink.Insert();
    end;

    local procedure HasQtyToAsm(ContratoPlanningLine: Record "Contrato Planning Line"; AsmHeader: Record "Assembly Header"): Boolean
    begin
        if ContratoPlanningLine."Qty. to Assemble (Base)" = 0 then
            exit(false);
        if AsmHeader."Quantity to Assemble (Base)" = 0 then
            exit(false);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyUsageLink(var ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyContratoJnlLine(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoJournalLine2: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoLedgEntryInsert(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostItem(var ContratoJournalLine2: Record "Contrato Journal Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterRunCode(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoLedgEntryNo: Integer; var ContratoRegister: Record "Contrato Register"; var NextEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckContrato(var ContratoJournalLine: Record "Contrato Journal Line"; Contrato: Record Contrato; var IsHandled: Boolean; var ContratoRegister: Record "Contrato Register"; var NextEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetAndCheckContrato(var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyUsageLink(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateContratoLedgEntry(var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean; var ContratoLedgEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateContratoRegister(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetContratoConsumptionValueEntry(var ContratoJournalLine: Record "Contrato Journal Line"; var Result: Boolean; var IsHandled: Boolean; var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoLedgEntryInsert(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoPlanningReservationExists(ItemNo: Code[20]; ContratoNo: Code[20]; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemPosting(var ContratoJournalLine: Record "Contrato Journal Line"; var NextEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyValueEntry(var ValueEntry: Record "Value Entry"; ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostResource(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoJnlLine2: Record "Contrato Journal Line"; var EntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunWithCheck(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateContratoJnlLineAmount(var ContratoJnlLineToUpdate: Record "Contrato Journal Line"; var RemainingAmount: Decimal; var RemainingAmountLCY: Decimal; var RemainingQtyToTrack: Decimal; AmtRoundingPrecision: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateContratoJnlLineResourceGroupNo(var ContratoJnlLine2: Record "Contrato Journal Line"; ResJnlLine: Record "Res. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckContratoOnBeforeTestContratoTaskType(var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCalcShouldPostUsage(var ContratoJournalLine2: Record "Contrato Journal Line"; var ShouldPostUsage: Boolean; var ContratoLedgEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateContratoLedgEntryOnBeforeAssignQtyCostPrice(var ContratoLedgEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateContratoLedgerEntryOnAfterAssignLedgerEntryTypeAndNo(var ContratoLedgEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line"; GLEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetContratoConsumptionValueEntryFilter(var ValueEntry: Record "Value Entry"; ContratoJournalLine: Record "Contrato Journal Line"; LocalContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemOnAfterApplyItemTracking(var ContratoJournalLine: Record "Contrato Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var SkipContratoLedgerEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemOnAfterSetSkipContratoLedgerEntry(var ContratoJnlLine2: Record "Contrato Journal Line"; ItemLedgEntry: Record "Item Ledger Entry"; var SkipContratoLedgerEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemOnBeforeGetContratoConsumptionValueEntry(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemOnBeforeUpdateTotalAmounts(var ContratoJournalLine: Record "Contrato Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry"; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemOnBeforeAssignItemJnlLine(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoJournalLine2: Record "Contrato Journal Line"; var ItemJnlLine: Record "Item Journal Line"; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateContratoLedgEntryFromPostItem(var ContratoJournalLine: Record "Contrato Journal Line"; var ValueEntry: Record "Value Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemOnAfterPostWhseJnlLine(var ContratoJournalLine2: Record "Contrato Journal Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCheckLine(var ContratoJournalLine: Record "Contrato Journal Line"; CalledFromInvtPutawayPick: Boolean; var CheckLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNextEntryNo(var ContratoJournalLine: Record "Contrato Journal Line"; var NextEntryNo: Integer; var IsHandled: Boolean; var ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsertContratoRegisterOnBeforeInsert(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoRegister: Record "Contrato Register")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNextEntryNo(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var NextEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateContratoJnlLineTotalAmounts(var ContratoJournalLine: Record "Contrato Journal Line"; AmtRoundingPrecision: Decimal; GLAmtRoundingPrecision: Decimal)
    begin
    end;
}

