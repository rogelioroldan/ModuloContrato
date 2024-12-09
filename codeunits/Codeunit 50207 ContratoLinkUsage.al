codeunit 50207 "Contrato Link Usage"
{
    Permissions = TableData "Contrato Usage Link" = rimd;

    trigger OnRun()
    begin
    end;

    var
        UOMMgt: Codeunit "Unit of Measure Management";
        CalledFromInvtPutawayPick: Boolean;

        Text001: Label 'The specified %1 does not have %2 enabled.', Comment = 'The specified Project Planning Line does not have Usage Link enabled.';
        ConfirmUsageWithBlankLineTypeQst: Label 'Usage will not be linked to the project planning line because the Line Type field is empty.\\Do you want to continue?';

    internal procedure ApplyUsage(ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line"; IsCalledFromInventoryPutawayPick: Boolean)
    begin
        CalledFromInvtPutawayPick := IsCalledFromInventoryPutawayPick;
        ApplyUsage(ContratoLedgerEntry, ContratoJournalLine);
    end;

    procedure ApplyUsage(ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
        if ContratoJournalLine."Contrato Planning Line No." = 0 then
            MatchUsageUnspecified(ContratoLedgerEntry, ContratoJournalLine."Line Type" = ContratoJournalLine."Line Type"::" ")
        else
            MatchUsageSpecified(ContratoLedgerEntry, ContratoJournalLine);

        OnAfterApplyUsage(ContratoLedgerEntry, ContratoJournalLine);
    end;

    local procedure MatchUsageUnspecified(ContratoLedgerEntry: Record "Contrato Ledger Entry"; EmptyLineType: Boolean)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoUsageLink: Record "Contrato Usage Link";
        Confirmed, IsHandled : Boolean;
        MatchedQty: Decimal;
        MatchedTotalCost: Decimal;
        MatchedLineAmount: Decimal;
        RemainingQtyToMatch, RemainingQtyToMatchPerUoM : Decimal;
    begin
        RemainingQtyToMatch := ContratoLedgerEntry."Quantity (Base)";
        repeat
            if not FindMatchingContratoPlanningLine(ContratoPlanningLine, ContratoLedgerEntry) then
                if EmptyLineType then begin
                    OnMatchUsageUnspecifiedOnBeforeConfirm(ContratoPlanningLine, ContratoLedgerEntry, Confirmed);
                    if not Confirmed then
                        Confirmed := Confirm(ConfirmUsageWithBlankLineTypeQst, false);
                    if not Confirmed then
                        Error('');
                    RemainingQtyToMatch := 0;
                end else
                    CreateContratoPlanningLine(ContratoPlanningLine, ContratoLedgerEntry, RemainingQtyToMatch);

            IsHandled := false;
            OnMatchUsageUnspecifiedOnBeforeCheckPostedQty(ContratoPlanningLine, ContratoLedgerEntry, RemainingQtyToMatch, IsHandled);
            if not IsHandled then begin
                RemainingQtyToMatchPerUoM := UOMMgt.CalcQtyFromBase(RemainingQtyToMatch, ContratoPlanningLine."Qty. per Unit of Measure");
                if (RemainingQtyToMatchPerUoM = ContratoPlanningLine."Qty. Posted") and (ContratoPlanningLine."Remaining Qty. (Base)" = 0) then
                    exit;
            end;

            if RemainingQtyToMatch <> 0 then begin
                ContratoUsageLink.Create(ContratoPlanningLine, ContratoLedgerEntry);
                if Abs(RemainingQtyToMatch) > Abs(ContratoPlanningLine."Remaining Qty. (Base)") then
                    MatchedQty := ContratoPlanningLine."Remaining Qty. (Base)"
                else
                    MatchedQty := RemainingQtyToMatch;
                OnMatchUsageUnspecifiedOnAfterCalcMatchedQty(ContratoLedgerEntry, MatchedQty);
                MatchedTotalCost := (ContratoLedgerEntry."Total Cost" / ContratoLedgerEntry."Quantity (Base)") * MatchedQty;
                MatchedLineAmount := (ContratoLedgerEntry."Line Amount" / ContratoLedgerEntry."Quantity (Base)") * MatchedQty;

                OnBeforeContratoPlanningLineUse(ContratoPlanningLine, ContratoLedgerEntry);
                ContratoPlanningLine.Use(
                    UOMMgt.CalcQtyFromBase(
                        ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Unit of Measure Code",
                        MatchedQty, ContratoPlanningLine."Qty. per Unit of Measure"),
                    MatchedTotalCost, MatchedLineAmount, ContratoLedgerEntry."Posting Date", ContratoLedgerEntry."Currency Factor");
                RemainingQtyToMatch -= MatchedQty;
                OnMatchUsageUnspecifiedOnAfterUpdateRemainingQtyToMatch(ContratoLedgerEntry, RemainingQtyToMatch);
            end;
        until RemainingQtyToMatch = 0;
    end;

    local procedure MatchUsageSpecified(ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeMatchUsageSpecified(ContratoPlanningLine, ContratoJournalLine, ContratoLedgerEntry, IsHandled);
        if IsHandled then
            exit;

        ContratoPlanningLine.Get(ContratoLedgerEntry."Contrato No.", ContratoLedgerEntry."Contrato Task No.", ContratoJournalLine."Contrato Planning Line No.");
        if not ContratoPlanningLine."Usage Link" then
            Error(Text001, ContratoPlanningLine.TableCaption(), ContratoPlanningLine.FieldCaption("Usage Link"));

        HandleMatchUsageSpecifiedContratoPlanningLine(ContratoPlanningLine, ContratoJournalLine, ContratoLedgerEntry);

        OnAfterMatchUsageSpecified(ContratoPlanningLine, ContratoJournalLine, ContratoLedgerEntry);
    end;

    procedure HandleMatchUsageSpecifiedContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    var
        ContratoUsageLink: Record "Contrato Usage Link";
        PostedQtyBase: Decimal;
        TotalQtyBase: Decimal;
        TotalRemainingQtyPrePostBase: Decimal;
        PartialContratoPlanningLineQuantityPosting, UpdateQuantity : Boolean;
    begin
        if ContratoPlanningLine."Assemble to Order" then begin
            PostedQtyBase := AssembledQtyBase(ContratoPlanningLine);
            TotalRemainingQtyPrePostBase := ContratoPlanningLine."Qty. to Assemble (Base)" - AssembledQtyBase(ContratoPlanningLine);
        end else begin
            PostedQtyBase := ContratoPlanningLine."Quantity (Base)" - ContratoPlanningLine."Remaining Qty. (Base)";
            TotalRemainingQtyPrePostBase := ContratoJournalLine."Quantity (Base)" + ContratoJournalLine."Remaining Qty. (Base)";
        end;
        TotalQtyBase := PostedQtyBase + TotalRemainingQtyPrePostBase;
        OnBeforeHandleMatchUsageSpecifiedContratoPlanningLine(PostedQtyBase, TotalRemainingQtyPrePostBase, TotalQtyBase, ContratoPlanningLine, ContratoJournalLine);
        ContratoPlanningLine.SetBypassQtyValidation(true);

        if Abs(UOMMgt.CalcQtyFromBase(ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Unit of Measure Code", TotalQtyBase, ContratoPlanningLine."Qty. per Unit of Measure")) < Abs(ContratoPlanningLine.Quantity) then begin
            PartialContratoPlanningLineQuantityPosting := (ContratoLedgerEntry."Serial No." <> '') or (ContratoLedgerEntry."Lot No." <> '');
            HandleMatchUsageSpecifiedContratoPlanningLineOnAfterCalcPartialContratoPlanningLineQuantityPosting(ContratoPlanningLine, ContratoJournalLine, ContratoLedgerEntry, PartialContratoPlanningLineQuantityPosting);
        end;
        // CalledFromInvtPutawayPick - Skip this quantity validation for Inventory Pick posting as quantity cannot be updated with an active Warehouse Activity Line.
        UpdateQuantity := not (CalledFromInvtPutawayPick or PartialContratoPlanningLineQuantityPosting);
        OnHandleMatchUsageSpecifiedContratoPlanningLineOnBeforeUpdateQuantity(ContratoPlanningLine, ContratoJournalLine, UpdateQuantity);
        if UpdateQuantity then
            if (TotalQtyBase > ContratoPlanningLine.Quantity) or (ContratoPlanningLine.Quantity = 0) then
                ContratoPlanningLine.Validate(Quantity,
                    UOMMgt.CalcQtyFromBase(
                        ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Unit of Measure Code",
                        TotalQtyBase, ContratoPlanningLine."Qty. per Unit of Measure"));

        ContratoPlanningLine.CopyTrackingFromContratoLedgEntry(ContratoLedgerEntry);
        OnHandleMatchUsageSpecifiedContratoPlanningLineOnBeforeContratoPlanningLineUse(ContratoPlanningLine, ContratoJournalLine, ContratoLedgerEntry);
        ContratoPlanningLine.Use(
            UOMMgt.CalcQtyFromBase(
                ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Unit of Measure Code",
                ContratoLedgerEntry."Quantity (Base)", ContratoPlanningLine."Qty. per Unit of Measure"),
            ContratoLedgerEntry."Total Cost", ContratoLedgerEntry."Line Amount", ContratoLedgerEntry."Posting Date", ContratoLedgerEntry."Currency Factor");
        OnHandleMatchUsageSpecifiedContratoPlanningLineOnAfterContratoPlanningLineUse(ContratoPlanningLine, ContratoJournalLine, ContratoLedgerEntry);
        ContratoUsageLink.Create(ContratoPlanningLine, ContratoLedgerEntry);
    end;

    procedure FindMatchingContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry"): Boolean
    var
        Resource: Record Resource;
        "Filter": Text;
        ContratoPlanningLineFound: Boolean;
    begin
        ContratoPlanningLine.Reset();
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Schedule Line", Type, "No.", "Planning Date");
        ContratoPlanningLine.SetRange("Contrato No.", ContratoLedgerEntry."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", ContratoLedgerEntry."Contrato Task No.");
        ContratoPlanningLine.SetRange(Type, ContratoLedgerEntry.Type);
        ContratoPlanningLine.SetRange("No.", ContratoLedgerEntry."No.");
        ContratoPlanningLine.SetRange("Location Code", ContratoLedgerEntry."Location Code");
        ContratoPlanningLine.SetRange("Schedule Line", true);
        ContratoPlanningLine.SetRange("Usage Link", true);

        if ContratoLedgerEntry.Type = ContratoLedgerEntry.Type::Resource then begin
            Filter := Resource.GetUnitOfMeasureFilter(ContratoLedgerEntry."No.", ContratoLedgerEntry."Unit of Measure Code");
            ContratoPlanningLine.SetFilter("Unit of Measure Code", Filter);
        end;

        if (ContratoLedgerEntry."Line Type" = ContratoLedgerEntry."Line Type"::Billable) or
           (ContratoLedgerEntry."Line Type" = ContratoLedgerEntry."Line Type"::"Both Budget and Billable")
        then
            ContratoPlanningLine.SetRange("Contract Line", true);

        if ContratoLedgerEntry.Quantity > 0 then
            ContratoPlanningLine.SetFilter("Remaining Qty.", '>0')
        else
            ContratoPlanningLine.SetFilter("Remaining Qty.", '<0');

        case ContratoLedgerEntry.Type of
            ContratoLedgerEntry.Type::Item:
                ContratoPlanningLine.SetRange("Variant Code", ContratoLedgerEntry."Variant Code");
            ContratoLedgerEntry.Type::Resource:
                ContratoPlanningLine.SetRange("Work Type Code", ContratoLedgerEntry."Work Type Code");
        end;

        // Match most specific Contrato Planning Line.
        OnFindMatchingContratoPlanningLineOnBeforeMatchSpecificContratoPlanningLine(ContratoPlanningLine, ContratoLedgerEntry);
        if ContratoPlanningLine.FindFirst() then
            exit(true);

        ContratoPlanningLine.SetRange("Variant Code", '');
        ContratoPlanningLine.SetRange("Work Type Code", '');

        // Match Location Code, while Variant Code and Work Type Code are blank.
        OnFindMatchingContratoPlanningLineOnBeforeMatchContratoPlanningLineLocation(ContratoPlanningLine, ContratoLedgerEntry);
        if ContratoPlanningLine.FindFirst() then
            exit(true);

        ContratoPlanningLine.SetRange("Location Code", '');

        case ContratoLedgerEntry.Type of
            ContratoLedgerEntry.Type::Item:
                ContratoPlanningLine.SetRange("Variant Code", ContratoLedgerEntry."Variant Code");
            ContratoLedgerEntry.Type::Resource:
                ContratoPlanningLine.SetRange("Work Type Code", ContratoLedgerEntry."Work Type Code");
        end;

        // Match Variant Code / Work Type Code, while Location Code is blank.
        if ContratoPlanningLine.FindFirst() then
            exit(true);

        ContratoPlanningLine.SetRange("Variant Code", '');
        ContratoPlanningLine.SetRange("Work Type Code", '');

        // Match unspecific Contrato Planning Line.
        if ContratoPlanningLine.FindFirst() then
            exit(true);

        ContratoPlanningLineFound := false;
        OnAfterFindMatchingContratoPlanningLine(ContratoPlanningLine, ContratoLedgerEntry, ContratoPlanningLineFound);
        exit(ContratoPlanningLineFound);
    end;

    local procedure CreateContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry"; RemainingQtyToMatch: Decimal)
    var
        Contrato: Record Contrato;
        ContratoPostLine: Codeunit "Contrato Post-Line";
    begin
        RemainingQtyToMatch :=
            UOMMgt.CalcQtyFromBase(
                ContratoLedgerEntry."No.", ContratoLedgerEntry."Variant Code", ContratoLedgerEntry."Unit of Measure Code",
                RemainingQtyToMatch, ContratoLedgerEntry."Qty. per Unit of Measure");

        case ContratoLedgerEntry."Line Type" of
            ContratoLedgerEntry."Line Type"::" ":
                ContratoLedgerEntry."Line Type" := ContratoLedgerEntry."Line Type"::Budget;
            ContratoLedgerEntry."Line Type"::Billable:
                ContratoLedgerEntry."Line Type" := ContratoLedgerEntry."Line Type"::"Both Budget and Billable";
        end;
        ContratoPlanningLine.Reset();
        ContratoPostLine.InsertPlLineFromLedgEntry(ContratoLedgerEntry);
        // Retrieve the newly created Contrato PlanningLine.
        ContratoPlanningLine.SetRange("Contrato No.", ContratoLedgerEntry."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", ContratoLedgerEntry."Contrato Task No.");
        ContratoPlanningLine.SetRange("Schedule Line", true);
        ContratoPlanningLine.FindLast();
        ContratoPlanningLine.Validate("Usage Link", true);
        ContratoPlanningLine.Validate(Quantity, RemainingQtyToMatch);
        OnBeforeModifyContratoPlanningLine(ContratoPlanningLine, ContratoLedgerEntry);
        ContratoPlanningLine.Modify();

        // If type is Both Budget And Billable and that type isn't allowed,
        // retrieve the Billabe line and modify the quantity as well.
        // Do the same if the type is G/L Account (Contrato Planning Lines will always be split in one Budget and one Billable line).
        Contrato.Get(ContratoLedgerEntry."Contrato No.");
        if (ContratoLedgerEntry."Line Type" = ContratoLedgerEntry."Line Type"::"Both Budget and Billable") and
           ((not Contrato."Allow Schedule/Contract Lines") or (ContratoLedgerEntry.Type = ContratoLedgerEntry.Type::"G/L Account"))
        then begin
            ContratoPlanningLine.Get(ContratoLedgerEntry."Contrato No.", ContratoLedgerEntry."Contrato Task No.", ContratoPlanningLine."Line No." + 10000);
            ContratoPlanningLine.Validate(Quantity, RemainingQtyToMatch);
            ContratoPlanningLine.Modify();
            ContratoPlanningLine.Get(ContratoLedgerEntry."Contrato No.", ContratoLedgerEntry."Contrato Task No.", ContratoPlanningLine."Line No." - 10000);
        end;
    end;

    local procedure AssembledQtyBase(var ContratoPlanningLine: Record "Contrato Planning Line") AssembledQty: Decimal
    var
        PostedATOLink: Record "Posted Assemble-to-Order Link";
    begin
        PostedATOLink.SetCurrentKey("Job No.", "Job Task No.", "Document Line No.");
        PostedATOLink.SetRange("Job No.", ContratoPlanningLine."Contrato No.");
        PostedATOLink.SetRange("Job Task No.", ContratoPlanningLine."Contrato Task No.");
        PostedATOLink.SetRange("Document Line No.", ContratoPlanningLine."Line No.");
        if PostedATOLink.FindSet() then
            repeat
                AssembledQty += PostedATOLink."Assembled Quantity (Base)";
            until PostedATOLink.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindMatchingContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLineFound: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMatchUsageSpecified(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoLedgerEntry: Record "Contrato Ledger Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoPlanningLineUse(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMatchUsageSpecified(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleMatchUsageSpecifiedContratoPlanningLineOnAfterContratoPlanningLineUse(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleMatchUsageSpecifiedContratoPlanningLineOnBeforeContratoPlanningLineUse(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMatchUsageUnspecifiedOnBeforeConfirm(ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry"; var Confirmed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMatchUsageUnspecifiedOnAfterCalcMatchedQty(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var MatchedQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMatchUsageUnspecifiedOnAfterUpdateRemainingQtyToMatch(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var RemainingQtyToMatch: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindMatchingContratoPlanningLineOnBeforeMatchSpecificContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindMatchingContratoPlanningLineOnBeforeMatchContratoPlanningLineLocation(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure HandleMatchUsageSpecifiedContratoPlanningLineOnAfterCalcPartialContratoPlanningLineQuantityPosting(ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry"; var PartialContratoPlanningLineQuantityPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleMatchUsageSpecifiedContratoPlanningLine(var PostedQtyBase: Decimal; var TotalQtyBase: Decimal; var TotalRemainingQtyPrePostBase: Decimal; ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleMatchUsageSpecifiedContratoPlanningLineOnBeforeUpdateQuantity(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line"; var UpdateQuantity: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMatchUsageUnspecifiedOnBeforeCheckPostedQty(ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry"; RemainingQtyToMatch: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyUsage(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;
}

