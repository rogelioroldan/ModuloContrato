codeunit 50204 "Contrato Jnl.-Post Batch"
{
    Permissions = TableData "Contrato Journal Batch" = rimd,
                  TableData "Contrato Journal Line" = rimd;
    TableNo = "Contrato Journal Line";

    trigger OnRun()
    begin
        ContratoJnlLine.Copy(Rec);
        ContratoJnlLine.SetAutoCalcFields();
        Code();
        Rec := ContratoJnlLine;
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlBatch: Record "Contrato Journal Batch";
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoJnlLine2: Record "Contrato Journal Line";
        ContratoJnlLine3: Record "Contrato Journal Line";
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoReg: Record "Contrato Register";
        ContratoJnlCheckLine: Codeunit "Contrato Jnl.-Check Line";
        ContratoJnlPostLine: Codeunit "Contrato Jnl.-Post Line";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        Window: Dialog;
        ContratoRegNo: Integer;
        StartLineNo: Integer;
        LineCount: Integer;
        NoOfRecords: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        SuppressCommit: Boolean;

        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@\';
        Text004: Label 'Updating lines        #5###### @6@@@@@@@@@@@@@';
        Text005: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';

    local procedure "Code"()
    var
        InvtSetup: Record "Inventory Setup";
        InvtAdjmtHandler: Codeunit "Inventory Adjustment Handler";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        IsHandled: Boolean;
    begin
        OnBeforeCode(ContratoJnlLine, SuppressCommit);

        ContratoJnlLine.SetRange("Journal Template Name", ContratoJnlLine."Journal Template Name");
        ContratoJnlLine.SetRange("Journal Batch Name", ContratoJnlLine."Journal Batch Name");
        ContratoJnlLine.SetFilter(Quantity, '<> 0');
        OnCodeOnAfterFilterContratoJnlLine(ContratoJnlLine);
        ContratoJnlLine.LockTable();

        ContratoJnlTemplate.Get(ContratoJnlLine."Journal Template Name");
        ContratoJnlBatch.Get(ContratoJnlLine."Journal Template Name", ContratoJnlLine."Journal Batch Name");

        if ContratoJnlTemplate.Recurring then begin
            ContratoJnlLine.SetRange("Posting Date", 0D, WorkDate());
            ContratoJnlLine.SetFilter("Expiration Date", '%1 | %2..', 0D, WorkDate());
        end;

        if not ContratoJnlLine.Find('=><') then begin
            ContratoJnlLine."Line No." := 0;
            if not SuppressCommit then
                Commit();
            exit;
        end;

        if GuiAllowed() then begin
            if ContratoJnlTemplate.Recurring then
                Window.Open(
                Text001 +
                Text002 +
                Text003 +
                Text004)
            else
                Window.Open(
                Text001 +
                Text002 +
                Text005);
            Window.Update(1, ContratoJnlLine."Journal Batch Name");
        end;

        // Check lines
        OnCodeOnBeforeCheckLines(ContratoJnlLine);
        LineCount := 0;
        StartLineNo := ContratoJnlLine."Line No.";
        repeat
            LineCount := LineCount + 1;
            if GuiAllowed() then
                Window.Update(2, LineCount);
            CheckRecurringLine(ContratoJnlLine);
            ContratoJnlCheckLine.RunCheck(ContratoJnlLine);
            OnAfterCheckJnlLine(ContratoJnlLine);
            if ContratoJnlLine.Next() = 0 then
                ContratoJnlLine.Find('-');
        until ContratoJnlLine."Line No." = StartLineNo;
        NoOfRecords := LineCount;

        // Find next register no.
        ContratoLedgEntry.LockTable();
        if ContratoLedgEntry.FindLast() then;
        ContratoReg.LockTable();
        if ContratoReg.FindLast() and (ContratoReg."To Entry No." = 0) then
            ContratoRegNo := ContratoReg."No."
        else
            ContratoRegNo := ContratoReg."No." + 1;

        // Post lines
        LineCount := 0;
        LastDocNo := '';
        LastDocNo2 := '';
        LastPostedDocNo := '';
        ContratoJnlLine.Find('-');
        repeat
            LineCount := LineCount + 1;
            if GuiAllowed() then begin
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
            end;
            if not ContratoJnlLine.EmptyLine() and
                (ContratoJnlBatch."No. Series" <> '') and
                (ContratoJnlLine."Document No." <> LastDocNo2)
            then
                ContratoJnlLine.TestField("Document No.", NoSeriesBatch.GetNextNo(ContratoJnlBatch."No. Series", ContratoJnlLine."Posting Date"));
            if not ContratoJnlLine.EmptyLine() then
                LastDocNo2 := ContratoJnlLine."Document No.";
            MakeRecurringTexts(ContratoJnlLine);
            if ContratoJnlLine."Posting No. Series" = '' then begin
                ContratoJnlLine."Posting No. Series" := ContratoJnlBatch."No. Series";
                IsHandled := false;
                OnBeforeTestDocumentNo(ContratoJnlLine, IsHandled);
                if not IsHandled then
                    ContratoJnlLine.TestField("Document No.");
            end else
                if not ContratoJnlLine.EmptyLine() then
                    if (ContratoJnlLine."Document No." = LastDocNo) and (ContratoJnlLine."Document No." <> '') then
                        ContratoJnlLine."Document No." := LastPostedDocNo
                    else begin
                        LastDocNo := ContratoJnlLine."Document No.";
                        ContratoJnlLine."Document No." := NoSeriesBatch.GetNextNo(ContratoJnlLine."Posting No. Series", ContratoJnlLine."Posting Date");
                        LastPostedDocNo := ContratoJnlLine."Document No.";
                    end;
            OnBeforeContratoJnlPostLine(ContratoJnlLine);
            ContratoJnlPostLine.RunWithCheck(ContratoJnlLine);
            OnAfterContratoJnlPostLine(ContratoJnlLine);
        until ContratoJnlLine.Next() = 0;

        InvtSetup.Get();
        if InvtSetup.AutomaticCostAdjmtRequired() then
            InvtAdjmtHandler.MakeInventoryAdjustment(true, InvtSetup."Automatic Cost Posting");

        OnCodeOnAfterMakeMultiLevelAdjmt(ContratoJnlLine);

        // Copy register no. and current journal batch name to the Contrato journal
        if not ContratoReg.FindLast() or (ContratoReg."No." <> ContratoRegNo) then
            ContratoRegNo := 0;

        ContratoJnlLine.Init();
        ContratoJnlLine."Line No." := ContratoRegNo;

        UpdateAndDeleteLines();
        OnAfterPostJnlLines(ContratoJnlBatch, ContratoJnlLine, ContratoRegNo);

        if not SuppressCommit then
            Commit();

        UpdateAnalysisView.UpdateAll(0, true);
        UpdateItemAnalysisView.UpdateAll(0, true);
        if not SuppressCommit then
            Commit();
    end;

    local procedure CheckRecurringLine(var ContratoJnlLine2: Record "Contrato Journal Line")
    var
        TempDateFormula: DateFormula;
    begin
        if ContratoJnlLine2."No." <> '' then
            if ContratoJnlTemplate.Recurring then begin
                ContratoJnlLine2.TestField("Recurring Method");
                ContratoJnlLine2.TestField("Recurring Frequency");
                if ContratoJnlLine2."Recurring Method" = ContratoJnlLine2."Recurring Method"::Variable then
                    ContratoJnlLine2.TestField(Quantity);
            end else begin
                ContratoJnlLine2.TestField("Recurring Method", 0);
                ContratoJnlLine2.TestField("Recurring Frequency", TempDateFormula);
            end;
    end;

    local procedure MakeRecurringTexts(var ContratoJnlLine2: Record "Contrato Journal Line")
    begin
        if (ContratoJnlLine2."No." <> '') and (ContratoJnlLine2."Recurring Method" <> 0) then
            AccountingPeriod.MakeRecurringTexts(ContratoJnlLine2."Posting Date", ContratoJnlLine2."Document No.", ContratoJnlLine2.Description);
    end;

    local procedure UpdateAndDeleteLines()
    var
        IsHandled: Boolean;
    begin
        OnBeforeUpdateAndDeleteLines(ContratoJnlLine);

        if ContratoRegNo <> 0 then
            if ContratoJnlTemplate.Recurring then begin
                // Recurring journal
                LineCount := 0;
                ContratoJnlLine2.CopyFilters(ContratoJnlLine);
                ContratoJnlLine2.Find('-');
                repeat
                    LineCount := LineCount + 1;
                    if GuiAllowed() then begin
                        Window.Update(5, LineCount);
                        Window.Update(6, Round(LineCount / NoOfRecords * 10000, 1));
                    end;
                    if ContratoJnlLine2."Posting Date" <> 0D then
                        ContratoJnlLine2.Validate("Posting Date", CalcDate(ContratoJnlLine2."Recurring Frequency", ContratoJnlLine2."Posting Date"));
                    if (ContratoJnlLine2."Recurring Method" = ContratoJnlLine2."Recurring Method"::Variable) and
                        (ContratoJnlLine2."No." <> '')
                    then
                        ContratoJnlLine2.DeleteAmounts();
                    ContratoJnlLine2.Modify();
                until ContratoJnlLine2.Next() = 0;
            end else begin
                // Not a recurring journal
                ContratoJnlLine2.CopyFilters(ContratoJnlLine);
                ContratoJnlLine2.SetFilter("No.", '<>%1', '');
                if ContratoJnlLine2.Find() then; // Remember the last line
                ContratoJnlLine3.Copy(ContratoJnlLine);
                IsHandled := false;
                OnBeforeDeleteNonRecJnlLines(ContratoJnlLine3, IsHandled, ContratoJnlLine, ContratoJnlLine2);
                if not IsHandled then begin
                    ContratoJnlLine3.DeleteAll();
                    ContratoJnlLine3.Reset();
                    ContratoJnlLine3.SetRange("Journal Template Name", ContratoJnlLine."Journal Template Name");
                    ContratoJnlLine3.SetRange("Journal Batch Name", ContratoJnlLine."Journal Batch Name");
                    if ContratoJnlTemplate."Increment Batch Name" then
                        if not ContratoJnlLine3.FindLast() then
                            if IncStr(ContratoJnlLine."Journal Batch Name") <> '' then begin
                                ContratoJnlBatch.Delete();
                                ContratoJnlBatch.Name := IncStr(ContratoJnlLine."Journal Batch Name");
                                if ContratoJnlBatch.Insert() then;
                                ContratoJnlLine."Journal Batch Name" := ContratoJnlBatch.Name;
                            end;
                    ContratoJnlLine3.SetRange("Journal Batch Name", ContratoJnlLine."Journal Batch Name");
                    IsHandled := false;
                    OnUpdateAndDeleteLinesOnBeforeSetUpNewLine(ContratoJnlBatch, ContratoJnlLine3, IsHandled);
                    if not IsHandled then
                        if (ContratoJnlBatch."No. Series" = '') and not ContratoJnlLine3.FindLast() and (ContratoRegNo = 0) then begin
                            ContratoJnlLine3.Init();
                            ContratoJnlLine3."Journal Template Name" := ContratoJnlLine."Journal Template Name";
                            ContratoJnlLine3."Journal Batch Name" := ContratoJnlLine."Journal Batch Name";
                            ContratoJnlLine3."Line No." := 10000;
                            ContratoJnlLine3.Insert();
                            ContratoJnlLine3.SetUpNewLine(ContratoJnlLine2);
                            ContratoJnlLine3.Modify();
                        end;
                end;
            end;

        NoSeriesBatch.SaveState();
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckJnlLine(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoJnlPostLine(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostJnlLines(var ContratoJournalBatch: Record "Contrato Journal Batch"; var ContratoJournalLine: Record "Contrato Journal Line"; ContratoRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var ContratoJournalLine: Record "Contrato Journal Line"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoJnlPostLine(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteNonRecJnlLines(var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean; var FromContratoJournalLine: Record "Contrato Journal Line"; var ContratoJournalLine2: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestDocumentNo(var ContratoJournalLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAndDeleteLines(var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterFilterContratoJnlLine(var ContratoJournalLine: Record "Contrato Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCheckLines(var ContratoJournalLine: Record "Contrato Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterMakeMultiLevelAdjmt(var ContratoJournalLine: Record "Contrato Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateAndDeleteLinesOnBeforeSetUpNewLine(ContratoJnlBatch: Record "Contrato Journal Batch"; var ContratoJnlLine3: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;
}

