codeunit 50206 "Contrato Jnl.-Check Line"
{
    TableNo = "Contrato Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        Location: Record Location;
        DimMgt: Codeunit DimensionManagement;
        TimeSheetMgt: Codeunit "Time Sheet Management";
        CalledFromInvtPutawayPick: Boolean;

        Text000: Label 'cannot be a closing date.';
        Text001: Label 'is not within your range of allowed posting dates.';
        CombinationBlockedErr: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5.', Comment = '%1 = table name, %2 = template name, %3 = batch name, %4 = line no., %5 - error text';
        DimensionCausedErr: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5.', Comment = '%1 = table name, %2 = template name, %3 = batch name, %4 = line no., %5 - error text';
        Text004: Label 'You must post more usage of %1 %2 in %3 %4 before you can post contrato journal %5 %6 = %7.', Comment = '%1=Item;%2=contratoJnlline."No.";%3=contrato;%4=contratoJnlline."contrato No.";%5=ProjectJnlline."Journal Batch Name";%6="Line No";%7=ProjectJnlline."Line No."';
        WhseRemainQtyPickedErr: Label 'You cannot post usage for project number %1 with project planning line %2 because a quantity of %3 remains to be picked.', Comment = '%1 = 12345, %2 = 1000, %3 = 5';

    procedure RunCheck(var ContratoJnlLine: Record "Contrato Journal Line")
    begin
        OnBeforeRunCheck(ContratoJnlLine);

        if ContratoJnlLine.EmptyLine() then
            exit;

        TestContratoJnlLine(ContratoJnlLine);

        TestContratoStatusOpen(ContratoJnlLine);

        CheckPostingDate(ContratoJnlLine);

        CheckDocumentDate(ContratoJnlLine);

        // if ContratoJnlLine."Time Sheet No." <> '' then
        //     TimeSheetMgt.CheckContratoJnlLine(ContratoJnlLine);

        CheckDim(ContratoJnlLine);

        CheckItemQuantityAndBinCode(ContratoJnlLine);

        TestContratoJnlLineChargeable(ContratoJnlLine);

        CheckWhseQtyPicked(ContratoJnlLine);

        OnAfterRunCheck(ContratoJnlLine);
    end;

    internal procedure SetCalledFromInvtPutawayPick(NewCalledFromInvtPutawayPick: Boolean)
    begin
        CalledFromInvtPutawayPick := NewCalledFromInvtPutawayPick;
    end;

    local procedure CheckItemQuantityAndBinCode(var ContratoJournalLine: Record "Contrato Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemQuantityAndBinCode(ContratoJournalLine, IsHandled);
        if IsHandled then
            exit;

        if ContratoJournalLine.Type <> ContratoJournalLine.Type::Item then
            exit;

        if (ContratoJournalLine."Quantity (Base)" < 0) and (ContratoJournalLine."Entry Type" = ContratoJournalLine."Entry Type"::Usage) then
            CheckItemQuantityContratoJnl(ContratoJournalLine);
        GetLocation(ContratoJournalLine."Location Code");
        if Location."Directed Put-away and Pick" then
            ContratoJournalLine.TestField("Bin Code", '', ErrorInfo.Create())
        else
            if Location."Bin Mandatory" and ContratoJournalLine.IsInventoriableItem() then
                ContratoJournalLine.TestField("Bin Code", ErrorInfo.Create());
    end;

    local procedure TestContratoStatusOpen(var ContratoJnlLine: Record "Contrato Journal Line")
    var
        Contrato: Record Contrato;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnRunCheckOnBeforeTestFieldContratoStatus(IsHandled, ContratoJnlLine);
        if IsHandled then
            exit;

        Contrato.Get(ContratoJnlLine."Contrato No.");
        Contrato.TestField(Status, Contrato.Status::Open, ErrorInfo.Create());
    end;

    local procedure TestContratoJnlLineChargeable(ContratoJnlLine: Record "Contrato Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestChargeable(ContratoJnlLine, IsHandled);
        if IsHandled then
            exit;

        if ContratoJnlLine."Line Type" in [ContratoJnlLine."Line Type"::Billable, ContratoJnlLine."Line Type"::"Both Budget and Billable"] then
            ContratoJnlLine.TestField(Chargeable, true, ErrorInfo.Create());
    end;

    local procedure CheckDocumentDate(ContratoJnlLine: Record "Contrato Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckDocumentDate(ContratoJnlLine, IsHandled);
        if IsHandled then
            exit;

        if (ContratoJnlLine."Document Date" <> 0D) and (ContratoJnlLine."Document Date" <> NormalDate(ContratoJnlLine."Document Date")) then
            ContratoJnlLine.FieldError("Document Date", ErrorInfo.Create(Text000, true));
    end;

    local procedure CheckPostingDate(ContratoJnlLine: Record "Contrato Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPostingDate(ContratoJnlLine, IsHandled);
        if IsHandled then
            exit;

        if NormalDate(ContratoJnlLine."Posting Date") <> ContratoJnlLine."Posting Date" then
            ContratoJnlLine.FieldError("Posting Date", ErrorInfo.Create(Text000, true));
        if not UserSetupManagement.IsPostingDateValid(ContratoJnlLine."Posting Date") then
            ContratoJnlLine.FieldError("Posting Date", ErrorInfo.Create(Text001, true));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure CheckDim(ContratoJnlLine: Record "Contrato Journal Line")
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckDim(ContratoJnlLine, IsHandled);
        if IsHandled then
            exit;

        if not DimMgt.CheckDimIDComb(ContratoJnlLine."Dimension Set ID") then
            Error(
                CombinationBlockedErr,
                ContratoJnlLine.TableCaption(), ContratoJnlLine."Journal Template Name", ContratoJnlLine."Journal Batch Name", ContratoJnlLine."Line No.",
                DimMgt.GetDimCombErr());

        TableID[1] := DATABASE::Contrato;
        No[1] := ContratoJnlLine."Contrato No.";
        TableID[2] := DimMgt.TypeToTableID2(ContratoJnlLine.Type.AsInteger());
        No[2] := ContratoJnlLine."No.";
        TableID[3] := DATABASE::"Resource Group";
        No[3] := ContratoJnlLine."Resource Group No.";
        TableID[4] := Database::Location;
        No[4] := ContratoJnlLine."Location Code";
        OnCheckDimOnAfterCreateDimTableID(ContratoJnlLine, TableID, No);

        if not DimMgt.CheckDimValuePosting(TableID, No, ContratoJnlLine."Dimension Set ID") then begin
            if ContratoJnlLine."Line No." <> 0 then
                Error(
                    ErrorInfo.Create(
                        StrSubstNo(
                            DimensionCausedErr,
                            ContratoJnlLine.TableCaption(), ContratoJnlLine."Journal Template Name", ContratoJnlLine."Journal Batch Name", ContratoJnlLine."Line No.",
                            DimMgt.GetDimValuePostingErr()),
                        true));
            Error(ErrorInfo.Create(DimMgt.GetDimValuePostingErr(), true));
        end;
    end;

    local procedure CheckItemQuantityContratoJnl(var ContratoJnlline: Record "Contrato Journal Line")
    var
        Item: Record Item;
        Contrato: Record Contrato;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemQuantityContratoJnl(ContratoJnlline, IsHandled);
        if IsHandled then
            exit;

        if ContratoJnlline.IsNonInventoriableItem() then
            exit;

        Contrato.Get(ContratoJnlline."Contrato No.");
        if (Contrato.GetQuantityAvailable(ContratoJnlline."No.", ContratoJnlline."Location Code", ContratoJnlline."Variant Code", 0, 2) +
            ContratoJnlline."Quantity (Base)") < 0
        then
            Error(
                ErrorInfo.Create(
                    StrSubstNo(
                        Text004, Item.TableCaption(), ContratoJnlline."No.", Contrato.TableCaption(),
                        ContratoJnlline."Contrato No.", ContratoJnlline."Journal Batch Name",
                        ContratoJnlline.FieldCaption("Line No."), ContratoJnlline."Line No."),
                    true));
    end;

    local procedure CheckWhseQtyPicked(var ContratoJournalLine: Record "Contrato Journal Line")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWhseQtyPicked(ContratoJournalLine, IsHandled);
        if IsHandled then
            exit;

        // if WhseValidateSourceLine.IsWhsePickRequiredForContratoJnlLine(ContratoJournalLine) or WhseValidateSourceLine.IsInventoryPickRequiredForContratoJnlLine(ContratoJournalLine) then
        //     if not CalledFromInvtPutawayPick then
        //         if ContratoPlanningLine.Get(ContratoJournalLine."Contrato No.", ContratoJournalLine."Contrato Task No.", ContratoJournalLine."Contrato Planning Line No.") and (ContratoPlanningLine."Qty. Picked" - ContratoPlanningLine."Qty. Posted" < ContratoJournalLine.Quantity - ContratoPlanningLine."Qty. to Assemble") then
        //             ContratoPlanningLine.FieldError("Qty. Picked", ErrorInfo.Create(StrSubstNo(WhseRemainQtyPickedErr, ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Line No.", ContratoJournalLine.Quantity + ContratoPlanningLine."Qty. Posted" - ContratoPlanningLine."Qty. Picked" - ContratoPlanningLine."Qty. to Assemble"), true));
    end;

    local procedure TestContratoJnlLine(ContratoJournalLine: Record "Contrato Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestContratoJnlLine(ContratoJournalLine, IsHandled);
        if IsHandled then
            exit;

        ContratoJournalLine.TestField("Contrato No.", ErrorInfo.Create());
        ContratoJournalLine.TestField("Contrato Task No.", ErrorInfo.Create());
        ContratoJournalLine.TestField("No.", ErrorInfo.Create());
        ContratoJournalLine.TestField("Posting Date", ErrorInfo.Create());
        ContratoJournalLine.TestField(Quantity, ErrorInfo.Create());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var ContratoJnlLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDocumentDate(var ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPostingDate(var ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWhseQtyPicked(var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var ContratoJnlLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDim(var ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemQuantityAndBinCode(ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemQuantityContratoJnl(var ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestContratoJnlLine(ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestChargeable(ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckDimOnAfterCreateDimTableID(ContratoJournalLine: Record "Contrato Journal Line"; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunCheckOnBeforeTestFieldContratoStatus(var IsHandled: Boolean; var ContratoJnlLine: Record "Contrato Journal Line")
    begin
    end;
}

