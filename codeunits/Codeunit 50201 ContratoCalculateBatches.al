codeunit 50201 "Contrato Calculate Batches"
{

    trigger OnRun()
    begin
    end;

    var
        ContratoDiffBuffer: array[2] of Record "Contrato Difference Buffer" temporary;
        PeriodLength2: DateFormula;

        Text000: Label '%1 lines were successfully transferred to the journal.';
        Text001: Label 'There is no remaining usage on the project(s).';
        Text002: Label 'The lines were successfully changed.';
        Text003: Label 'The From Date is later than the To Date.';
        Text004: Label 'You must specify %1.';
        Text005: Label 'There is nothing to invoice.';
        Text006: Label '1 invoice is created.';
        Text007: Label '%1 invoices are created.';
        Text008: Label 'The selected entries were successfully transferred to planning lines.';
        Text009: Label 'Total Cost,Total Price,Line Discount Amount,Line Amount';

    procedure SplitLines(var JT2: Record "Contrato Task"): Integer
    var
        JT: Record "Contrato Task";
        ContratoPlanningLine: Record "Contrato Planning Line";
        NoOfLinesSplitted: Integer;
    begin
        ContratoPlanningLine.LockTable();
        JT.LockTable();
        JT := JT2;
        JT.Find();
        ContratoPlanningLine.SetRange("Contrato No.", JT."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", JT."Contrato Task No.");
        ContratoPlanningLine.SetFilter("Planning Date", JT2.GetFilter("Planning Date Filter"));
        if ContratoPlanningLine.Find('-') then
            repeat
                if ContratoPlanningLine."Line Type" = ContratoPlanningLine."Line Type"::"Both Budget and Billable" then
                    if SplitOneLine(ContratoPlanningLine) then
                        NoOfLinesSplitted += 1;
            until ContratoPlanningLine.Next() = 0;
        exit(NoOfLinesSplitted);
    end;

    local procedure SplitOneLine(ContratoPlanningLine: Record "Contrato Planning Line"): Boolean
    var
        ContratoPlanningLine2: Record "Contrato Planning Line";
        NextLineNo: Integer;
    begin
        ContratoPlanningLine.TestField("Contrato No.");
        ContratoPlanningLine.TestField("Contrato Task No.");
        ContratoPlanningLine2 := ContratoPlanningLine;
        ContratoPlanningLine2.SetRange("Contrato No.", ContratoPlanningLine2."Contrato No.");
        ContratoPlanningLine2.SetRange("Contrato Task No.", ContratoPlanningLine2."Contrato Task No.");
        NextLineNo := ContratoPlanningLine."Line No." + 10000;
        if ContratoPlanningLine2.Next() <> 0 then
            NextLineNo := (ContratoPlanningLine."Line No." + ContratoPlanningLine2."Line No.") div 2;
        ContratoPlanningLine.Validate("Line Type", ContratoPlanningLine."Line Type"::Billable);
        ContratoPlanningLine.Modify();
        ContratoPlanningLine.Validate("Line Type", ContratoPlanningLine."Line Type"::Budget);
        ContratoPlanningLine.ClearTracking();
        ContratoPlanningLine."Line No." := NextLineNo;
        ContratoPlanningLine.InitContratoPlanningLine();
        OnBeforeContratoPlanningLineInsert(ContratoPlanningLine);
        ContratoPlanningLine.Insert(true);
        exit(true);
    end;

    procedure TransferToPlanningLine(var ContratoLedgEntry: Record "Contrato Ledger Entry"; LineType: Integer)
    var
        ContratoPostLine: Codeunit "Contrato Post-Line";
    begin
        ContratoLedgEntry.LockTable();
        if ContratoLedgEntry.Find('-') then
            repeat
                OnBeforeTransferToPlanningLine(ContratoLedgEntry);
                ContratoLedgEntry.TestField("Contrato No.");
                ContratoLedgEntry.TestField("Contrato Task No.");
                ContratoLedgEntry.TestField("Entry Type", ContratoLedgEntry."Entry Type"::Usage);
                ContratoLedgEntry."Line Type" := Enum::"Contrato Line Type".FromInteger(LineType);
                Clear(ContratoPostLine);
                ContratoPostLine.InsertPlLineFromLedgEntry(ContratoLedgEntry);
            until ContratoLedgEntry.Next() = 0;
        Commit();
        Message(Text008);
    end;

    procedure ChangePlanningDates(JT: Record "Contrato Task"; ScheduleLine: Boolean; ContractLine: Boolean; PeriodLength: DateFormula; FixedDate: Date; StartingDate: Date; EndingDate: Date)
    var
        Contrato: Record Contrato;
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoPlanningLine.LockTable();
        JT.LockTable();

        if EndingDate = 0D then
            EndingDate := DMY2Date(31, 12, 9999);
        if EndingDate < StartingDate then
            Error(Text003);
        JT.TestField("Contrato No.");
        JT.TestField("Contrato Task No.");
        Contrato.Get(JT."Contrato No.");
        if Contrato.Blocked = Contrato.Blocked::All then
            Contrato.TestBlocked();
        JT.Find();
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        ContratoPlanningLine.SetRange("Contrato No.", Contrato."No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", JT."Contrato Task No.");

        if ScheduleLine and not ContractLine then
            ContratoPlanningLine.SetRange("Schedule Line", true);
        if not ScheduleLine and ContractLine then
            ContratoPlanningLine.SetRange("Contract Line", true);
        ContratoPlanningLine.SetRange("Planning Date", StartingDate, EndingDate);
        if ContratoPlanningLine.Find('-') then
            repeat
                ContratoPlanningLine.CalcFields("Qty. Transferred to Invoice");
                if ContratoPlanningLine."Qty. Transferred to Invoice" = 0 then begin
                    ContratoPlanningLine.TestField("Planning Date");
                    if FixedDate > 0D then
                        ContratoPlanningLine."Planning Date" := FixedDate
                    else
                        if PeriodLength <> PeriodLength2 then
                            ContratoPlanningLine."Planning Date" :=
                              CalcDate(PeriodLength, ContratoPlanningLine."Planning Date");
                    ContratoPlanningLine."Last Date Modified" := Today;
                    ContratoPlanningLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(ContratoPlanningLine."User ID"));
                    OnChangePlanningDatesOnBeforeContratoPlanningLineModify(ContratoPlanningLine);
                    ContratoPlanningLine.Modify();
                end;
            until ContratoPlanningLine.Next() = 0;
    end;

    procedure ChangeCurrencyDates(JT: Record "Contrato Task"; scheduleLine: Boolean; ContractLine: Boolean; PeriodLength: DateFormula; FixedDate: Date; StartingDate: Date; EndingDate: Date)
    var
        Contrato: Record Contrato;
        ContratoPlanningLine: Record "Contrato Planning Line";
        ForceDateUpdate: Boolean;
    begin
        if EndingDate = 0D then
            EndingDate := DMY2Date(31, 12, 9999);
        if EndingDate < StartingDate then
            Error(Text003);
        JT.TestField("Contrato No.");
        JT.TestField("Contrato Task No.");
        Contrato.Get(JT."Contrato No.");
        if Contrato.Blocked = Contrato.Blocked::All then
            Contrato.TestBlocked();
        JT.Find();
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        ContratoPlanningLine.SetRange("Contrato No.", Contrato."No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", JT."Contrato Task No.");

        if scheduleLine and not ContractLine then
            ContratoPlanningLine.SetRange("Schedule Line", true);
        if not scheduleLine and ContractLine then
            ContratoPlanningLine.SetRange("Contract Line", true);
        ContratoPlanningLine.SetRange("Currency Date", StartingDate, EndingDate);
        if ContratoPlanningLine.Find('-') then
            repeat
                ContratoPlanningLine.CalcFields("Qty. Transferred to Invoice");
                ForceDateUpdate := false;
                OnChangeCurrencyDatesOnBeforeChangeCurrencyDate(ContratoPlanningLine, ForceDateUpdate);
                if (ContratoPlanningLine."Qty. Transferred to Invoice" = 0) or ForceDateUpdate then begin
                    ContratoPlanningLine.TestField("Planning Date");
                    ContratoPlanningLine.TestField("Currency Date");
                    if FixedDate > 0D then begin
                        ContratoPlanningLine."Currency Date" := FixedDate;
                        ContratoPlanningLine."Document Date" := FixedDate;
                    end else
                        if PeriodLength <> PeriodLength2 then begin
                            ContratoPlanningLine."Currency Date" :=
                              CalcDate(PeriodLength, ContratoPlanningLine."Currency Date");
                            ContratoPlanningLine."Document Date" :=
                              CalcDate(PeriodLength, ContratoPlanningLine."Document Date");
                        end;
                    ContratoPlanningLine.Validate("Currency Date");
                    ContratoPlanningLine."Last Date Modified" := Today;
                    ContratoPlanningLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(ContratoPlanningLine."User ID"));
                    OnChangeCurrencyDatesOnBeforeContratoPlanningLineModify(ContratoPlanningLine);
                    ContratoPlanningLine.Modify(true);
                end;
            until ContratoPlanningLine.Next() = 0;
    end;

    procedure ChangeDatesEnd()
    begin
        Commit();
        Message(Text002);
    end;

    procedure CreateJT(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateJT(IsHandled, ContratoPlanningLine);
        if IsHandled then
            exit;

        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Text then
            exit;
        if not ContratoPlanningLine."Schedule Line" then
            exit;
        Contrato.Get(ContratoPlanningLine."Contrato No.");
        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        ContratoDiffBuffer[1]."Contrato No." := ContratoPlanningLine."Contrato No.";
        ContratoDiffBuffer[1]."Contrato Task No." := ContratoPlanningLine."Contrato Task No.";
        ContratoDiffBuffer[1].Type := ContratoPlanningLine.Type;
        ContratoDiffBuffer[1]."No." := ContratoPlanningLine."No.";
        ContratoDiffBuffer[1]."Location Code" := ContratoPlanningLine."Location Code";
        ContratoDiffBuffer[1]."Variant Code" := ContratoPlanningLine."Variant Code";
        ContratoDiffBuffer[1]."Unit of Measure code" := ContratoPlanningLine."Unit of Measure Code";
        ContratoDiffBuffer[1]."Work Type Code" := ContratoPlanningLine."Work Type Code";
        ContratoDiffBuffer[1].Quantity := ContratoPlanningLine.Quantity;
        ContratoDiffBuffer[1]."Line Amount" := ContratoPlanningLine."Line Amount";
        OnCreateJTOnBeforeAssigneContratoDiffBuffer2(ContratoDiffBuffer, ContratoPlanningLine);
        ContratoDiffBuffer[2] := ContratoDiffBuffer[1];
        if ContratoDiffBuffer[2].Find() then begin
            ContratoDiffBuffer[2].Quantity := ContratoDiffBuffer[2].Quantity + ContratoDiffBuffer[1].Quantity;
            ContratoDiffBuffer[2].Modify();
        end else
            ContratoDiffBuffer[1].Insert();
    end;

    procedure InitDiffBuffer()
    begin
        Clear(ContratoDiffBuffer);
        ContratoDiffBuffer[1].DeleteAll();
    end;

    procedure PostDiffBuffer(DocNo: Code[20]; PostingDate: Date; TemplateName: Code[10]; BatchName: Code[10])
    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlBatch: Record "Contrato Journal Batch";
        NextLineNo: Integer;
        LineNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostDiffBuffer(ContratoDiffBuffer, IsHandled);
        if IsHandled then
            exit;

        if ContratoDiffBuffer[1].Find('-') then
            repeat
                ContratoLedgEntry.SetCurrentKey("Contrato No.", "Contrato Task No.");
                ContratoLedgEntry.SetRange("Contrato No.", ContratoDiffBuffer[1]."Contrato No.");
                ContratoLedgEntry.SetRange("Contrato Task No.", ContratoDiffBuffer[1]."Contrato Task No.");
                ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Usage);
                ContratoLedgEntry.SetRange(Type, ContratoDiffBuffer[1].Type);
                ContratoLedgEntry.SetRange("No.", ContratoDiffBuffer[1]."No.");
                ContratoLedgEntry.SetRange("Location Code", ContratoDiffBuffer[1]."Location Code");
                ContratoLedgEntry.SetRange("Variant Code", ContratoDiffBuffer[1]."Variant Code");
                ContratoLedgEntry.SetRange("Unit of Measure Code", ContratoDiffBuffer[1]."Unit of Measure code");
                ContratoLedgEntry.SetRange("Work Type Code", ContratoDiffBuffer[1]."Work Type Code");
                OnPostDiffBufferOnAfterSetFilters(ContratoLedgEntry, ContratoDiffBuffer[1]);
                if ContratoLedgEntry.Find('-') then
                    repeat
                        ContratoDiffBuffer[1].Quantity := ContratoDiffBuffer[1].Quantity - ContratoLedgEntry.Quantity;
                    until ContratoLedgEntry.Next() = 0;
                OnPostDiffBufferOnBeforeModify(ContratoLedgEntry, ContratoDiffBuffer[1]);
                ContratoDiffBuffer[1].Modify();
            until ContratoDiffBuffer[1].Next() = 0;
        ContratoJnlLine.LockTable();
        ContratoJnlLine.Validate("Journal Template Name", TemplateName);
        ContratoJnlLine.Validate("Journal Batch Name", BatchName);
        ContratoJnlLine.SetRange("Journal Template Name", ContratoJnlLine."Journal Template Name");
        ContratoJnlLine.SetRange("Journal Batch Name", ContratoJnlLine."Journal Batch Name");
        if ContratoJnlLine.FindLast() then
            NextLineNo := ContratoJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        if ContratoDiffBuffer[1].Find('-') then
            repeat
                if ContratoDiffBuffer[1].Quantity <> 0 then begin
                    Clear(ContratoJnlLine);
                    ContratoJnlLine."Journal Template Name" := TemplateName;
                    ContratoJnlLine."Journal Batch Name" := BatchName;
                    ContratoJnlTemplate.Get(TemplateName);
                    ContratoJnlBatch.Get(TemplateName, BatchName);
                    ContratoJnlLine."Source Code" := ContratoJnlTemplate."Source Code";
                    ContratoJnlLine."Reason Code" := ContratoJnlBatch."Reason Code";
                    ContratoJnlLine.DontCheckStdCost();
                    ContratoJnlLine.Validate("Contrato No.", ContratoDiffBuffer[1]."Contrato No.");
                    ContratoJnlLine.Validate("Contrato Task No.", ContratoDiffBuffer[1]."Contrato Task No.");
                    ContratoJnlLine.Validate("Posting Date", PostingDate);
                    ContratoJnlLine.Validate(Type, ContratoDiffBuffer[1].Type);
                    ContratoJnlLine.Validate("No.", ContratoDiffBuffer[1]."No.");
                    ContratoJnlLine.Validate("Variant Code", ContratoDiffBuffer[1]."Variant Code");
                    ContratoJnlLine.Validate("Unit of Measure Code", ContratoDiffBuffer[1]."Unit of Measure code");
                    ContratoJnlLine.Validate("Location Code", ContratoDiffBuffer[1]."Location Code");
                    if ContratoDiffBuffer[1].Type = ContratoDiffBuffer[1].Type::Resource then
                        ContratoJnlLine.Validate("Work Type Code", ContratoDiffBuffer[1]."Work Type Code");
                    ContratoJnlLine."Document No." := DocNo;
                    ContratoJnlLine.Validate(Quantity, ContratoDiffBuffer[1].Quantity);
                    ContratoJnlLine.Validate("Unit Price", ContratoDiffBuffer[1]."Line Amount" / ContratoDiffBuffer[1].Quantity);
                    ContratoJnlLine."Line No." := NextLineNo;
                    NextLineNo := NextLineNo + 10000;
                    ContratoJnlLine.Insert(true);
                    OnPostDiffBufferOnAfterInsertContratoJnlLine(ContratoJnlLine, ContratoDiffBuffer[1]);
                    LineNo := LineNo + 1;
                end;
            until ContratoDiffBuffer[1].Next() = 0;
        Commit();
        if LineNo = 0 then
            Message(Text001)
        else
            Message(Text000, LineNo);
    end;

    procedure BatchError(PostingDate: Date; DocNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        if PostingDate = 0D then
            Error(Text004, GLEntry.FieldCaption("Posting Date"));
        if DocNo = '' then
            Error(Text004, GLEntry.FieldCaption("Document No."));
    end;

    procedure EndCreateInvoice(NoOfInvoices: Integer)
    begin
        Commit();
        if NoOfInvoices <= 0 then
            Message(Text005);
        if NoOfInvoices = 1 then
            Message(Text006);
        if NoOfInvoices > 1 then
            Message(Text007, NoOfInvoices);
    end;

    procedure CalculateActualToBudget(var Contrato: Record Contrato; JT: Record "Contrato Task"; var ContratoDiffBuffer2: Record "Contrato Difference Buffer"; var ContratoDiffBuffer3: Record "Contrato Difference Buffer"; CurrencyType: Option LCY,FCY)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoLedgEntry: Record "Contrato Ledger Entry";
    begin
        ClearAll();
        Clear(ContratoDiffBuffer);
        Clear(ContratoDiffBuffer2);
        Clear(ContratoDiffBuffer3);

        ContratoDiffBuffer[1].DeleteAll();
        ContratoDiffBuffer2.DeleteAll();
        ContratoDiffBuffer3.DeleteAll();

        JT.Find();
        ContratoPlanningLine.SetRange("Contrato No.", JT."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", JT."Contrato Task No.");
        ContratoPlanningLine.SetFilter("Planning Date", Contrato.GetFilter("Planning Date Filter"));

        ContratoLedgEntry.SetRange("Contrato No.", JT."Contrato No.");
        ContratoLedgEntry.SetRange("Contrato Task No.", JT."Contrato Task No.");
        ContratoLedgEntry.SetFilter("Posting Date", Contrato.GetFilter("Posting Date Filter"));

        if ContratoPlanningLine.Find('-') then
            repeat
                InsertDiffBuffer(ContratoLedgEntry, ContratoPlanningLine, 0, CurrencyType);
            until ContratoPlanningLine.Next() = 0;

        if ContratoLedgEntry.Find('-') then
            repeat
                InsertDiffBuffer(ContratoLedgEntry, ContratoPlanningLine, 1, CurrencyType);
            until ContratoLedgEntry.Next() = 0;

        if ContratoDiffBuffer[1].Find('-') then
            repeat
                if ContratoDiffBuffer[1]."Entry type" = ContratoDiffBuffer[1]."Entry type"::Budget then begin
                    ContratoDiffBuffer2 := ContratoDiffBuffer[1];
                    ContratoDiffBuffer2.Insert();
                end else begin
                    ContratoDiffBuffer3 := ContratoDiffBuffer[1];
                    ContratoDiffBuffer3."Entry type" := ContratoDiffBuffer3."Entry type"::Budget;
                    ContratoDiffBuffer3.Insert();
                end;
            until ContratoDiffBuffer[1].Next() = 0;
    end;

    local procedure InsertDiffBuffer(var ContratoLedgEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line"; LineType: Option Schedule,Usage; CurrencyType: Option LCY,FCY)
    begin
        OnBeforeInsertDiffBuffer(ContratoLedgEntry, ContratoPlanningLine, ContratoDiffBuffer, LineType, CurrencyType);

        if LineType = LineType::Schedule then begin
            if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Text then
                exit;
            if not ContratoPlanningLine."Schedule Line" then
                exit;
            ContratoDiffBuffer[1].Type := ContratoPlanningLine.Type;
            ContratoDiffBuffer[1]."No." := ContratoPlanningLine."No.";
            ContratoDiffBuffer[1]."Entry type" := ContratoDiffBuffer[1]."Entry type"::Budget;
            ContratoDiffBuffer[1]."Unit of Measure code" := ContratoPlanningLine."Unit of Measure Code";
            ContratoDiffBuffer[1]."Work Type Code" := ContratoPlanningLine."Work Type Code";
            ContratoDiffBuffer[1].Quantity := ContratoPlanningLine.Quantity;
            if CurrencyType = CurrencyType::LCY then begin
                ContratoDiffBuffer[1]."Total Cost" := ContratoPlanningLine."Total Cost (LCY)";
                ContratoDiffBuffer[1]."Line Amount" := ContratoPlanningLine."Line Amount (LCY)";
            end else begin
                ContratoDiffBuffer[1]."Total Cost" := ContratoPlanningLine."Total Cost";
                ContratoDiffBuffer[1]."Line Amount" := ContratoPlanningLine."Line Amount";
            end;
            ContratoDiffBuffer[2] := ContratoDiffBuffer[1];
            if ContratoDiffBuffer[2].Find() then begin
                ContratoDiffBuffer[2].Quantity :=
                    ContratoDiffBuffer[2].Quantity + ContratoDiffBuffer[1].Quantity;
                ContratoDiffBuffer[2]."Total Cost" :=
                    ContratoDiffBuffer[2]."Total Cost" + ContratoDiffBuffer[1]."Total Cost";
                ContratoDiffBuffer[2]."Line Amount" :=
                    ContratoDiffBuffer[2]."Line Amount" + ContratoDiffBuffer[1]."Line Amount";
                ContratoDiffBuffer[2].Modify();
            end else
                ContratoDiffBuffer[1].Insert();
        end;

        if LineType = LineType::Usage then begin
            if ContratoLedgEntry."Entry Type" <> ContratoLedgEntry."Entry Type"::Usage then
                exit;
            ContratoDiffBuffer[1].Type := ContratoLedgEntry.Type;
            ContratoDiffBuffer[1]."No." := ContratoLedgEntry."No.";
            ContratoDiffBuffer[1]."Entry type" := ContratoDiffBuffer[1]."Entry type"::Usage;
            ContratoDiffBuffer[1]."Unit of Measure code" := ContratoLedgEntry."Unit of Measure Code";
            ContratoDiffBuffer[1]."Work Type Code" := ContratoLedgEntry."Work Type Code";
            ContratoDiffBuffer[1].Quantity := ContratoLedgEntry.Quantity;
            if CurrencyType = CurrencyType::LCY then begin
                ContratoDiffBuffer[1]."Total Cost" := ContratoLedgEntry."Total Cost (LCY)";
                ContratoDiffBuffer[1]."Line Amount" := ContratoLedgEntry."Line Amount (LCY)";
            end else begin
                ContratoDiffBuffer[1]."Total Cost" := ContratoLedgEntry."Total Cost";
                ContratoDiffBuffer[1]."Line Amount" := ContratoLedgEntry."Line Amount";
            end;
            ContratoDiffBuffer[2] := ContratoDiffBuffer[1];
            if ContratoDiffBuffer[2].Find() then begin
                ContratoDiffBuffer[2].Quantity :=
                    ContratoDiffBuffer[2].Quantity + ContratoDiffBuffer[1].Quantity;
                ContratoDiffBuffer[2]."Total Cost" :=
                    ContratoDiffBuffer[2]."Total Cost" + ContratoDiffBuffer[1]."Total Cost";
                ContratoDiffBuffer[2]."Line Amount" :=
                    ContratoDiffBuffer[2]."Line Amount" + ContratoDiffBuffer[1]."Line Amount";
                ContratoDiffBuffer[2].Modify();
            end else
                ContratoDiffBuffer[1].Insert();
        end;

        OnAfterInsertDiffBuffer(ContratoLedgEntry, ContratoPlanningLine, ContratoDiffBuffer, LineType, CurrencyType);
    end;

    procedure GetCurrencyCode(var Contrato: Record Contrato; Type: Option "0","1","2","3"; CurrencyType: Option "Local Currency","Foreign Currency"): Text[50]
    var
        GLSetup: Record "General Ledger Setup";
        CurrencyCode: Code[20];
    begin
        GLSetup.Get();
        if CurrencyType = CurrencyType::"Local Currency" then
            CurrencyCode := GLSetup."LCY Code"
        else
            if Contrato."Currency Code" <> '' then
                CurrencyCode := Contrato."Currency Code"
            else
                CurrencyCode := GLSetup."LCY Code";
        exit(SelectStr(Type + 1, Text009) + ' (' + CurrencyCode + ')');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoPlanningLineInsert(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostDiffBuffer(var ContratoDiffBuffer: array[2] of Record "Contrato Difference Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferToPlanningLine(var ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateJTOnBeforeAssigneContratoDiffBuffer2(var ContratoDiffBuffer: array[2] of Record "Contrato Difference Buffer" temporary; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnChangeCurrencyDatesOnBeforeContratoPlanningLineModify(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnChangePlanningDatesOnBeforeContratoPlanningLineModify(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostDiffBufferOnAfterInsertContratoJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; var ContratoDiffBuffer: Record "Contrato Difference Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostDiffBufferOnBeforeModify(var ContratoLedgEntry: Record "Contrato Ledger Entry"; var ContratoDiffBuffer: Record "Contrato Difference Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostDiffBufferOnAfterSetFilters(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoDifferenceBuffer: Record "Contrato Difference Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateJT(var IsHanlded: Boolean; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertDiffBuffer(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoDiffBuffer: array[2] of Record "Contrato Difference Buffer" temporary; LineType: Option Schedule,Usage; CurrencyType: Option LCY,FCY)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertDiffBuffer(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoDiffBuffer: array[2] of Record "Contrato Difference Buffer" temporary; LineType: Option Schedule,Usage; CurrencyType: Option LCY,FCY)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnChangeCurrencyDatesOnBeforeChangeCurrencyDate(var ContratoPlanningLine: Record "Contrato Planning Line"; var ForceDateUpdate: Boolean)
    begin
    end;
}

