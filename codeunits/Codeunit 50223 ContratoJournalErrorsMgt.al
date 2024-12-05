codeunit 50223 "Contrato Journal Errors Mgt."
{
    SingleInstance = true;

    trigger OnRun()
    begin

    end;

    var
        TempErrorMessage: Record "Error Message" temporary;
        TempJobJnlLineModified: Record "Contrato Journal Line" temporary;
        TempDeletedJobJnlLine: Record "Contrato Journal Line" temporary;
        BackgroundErrorHandlingMgt: Codeunit "Background Error Handling Mgt.";
        FullBatchCheck: Boolean;

    procedure SetErrorMessages(var SourceTempErrorMessage: Record "Error Message" temporary)
    begin
        TempErrorMessage.Copy(SourceTempErrorMessage, true);
    end;

    procedure GetErrorMessages(var NewTempErrorMessage: Record "Error Message" temporary)
    begin
        NewTempErrorMessage.Copy(TempErrorMessage, true);
    end;

    procedure SetJobJnlLineOnModify(Rec: Record "Contrato Journal Line")
    begin
        if BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled() then
            SaveJobJournalLineToBuffer(Rec, TempJobJnlLineModified);
    end;

    local procedure SaveJobJournalLineToBuffer(JobJournalLine: Record "Contrato Journal Line"; var BufferLine: Record "Contrato Journal Line" temporary)
    begin
        if BufferLine.Get(JobJournalLine."Journal Template Name", JobJournalLine."Journal Batch Name", JobJournalLine."Line No.") then begin
            BufferLine.TransferFields(JobJournalLine);
            BufferLine.Modify();
        end else begin
            BufferLine := JobJournalLine;
            BufferLine.Insert();
        end;
    end;

    procedure GetJobJnlLinePreviousLineNo() PrevLineNo: Integer
    begin
        if TempJobJnlLineModified.FindFirst() then begin
            PrevLineNo := TempJobJnlLineModified."Line No.";
            if TempJobJnlLineModified.Delete() then;
        end;
    end;

    procedure SetFullBatchCheck(NewFullBatchCheck: Boolean)
    begin
        FullBatchCheck := NewFullBatchCheck;
    end;

    procedure GetDeletedJobJnlLine(var TempJobJnlLine: Record "Contrato Journal Line" temporary; ClearBuffer: Boolean): Boolean
    begin
        if TempDeletedJobJnlLine.FindSet() then begin
            repeat
                TempJobJnlLine := TempDeletedJobJnlLine;
                TempJobJnlLine.Insert();
            until TempDeletedJobJnlLine.Next() = 0;

            if ClearBuffer then
                TempDeletedJobJnlLine.DeleteAll();
            exit(true);
        end;

        exit(false);
    end;

    procedure CollectJobJnlCheckParameters(JobJnlLine: Record "Contrato Journal Line"; var ErrorHandlingParameters: Record "Error Handling Parameters")
    begin
        ErrorHandlingParameters."Journal Template Name" := JobJnlLine."Journal Template Name";
        ErrorHandlingParameters."Journal Batch Name" := JobJnlLine."Journal Batch Name";
        ErrorHandlingParameters."Line No." := JobJnlLine."Line No.";
        ErrorHandlingParameters."Full Batch Check" := FullBatchCheck;
        ErrorHandlingParameters."Previous Line No." := GetJobJnlLinePreviousLineNo();
    end;

    procedure InsertDeletedJobJnlLine(JobJnlLine: Record "Contrato Journal Line")
    begin
        if BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled() then begin
            TempDeletedJobJnlLine := JobJnlLine;
            if TempDeletedJobJnlLine.Insert() then;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contrato Journal", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteRecordEventJobJournal(var Rec: Record "Contrato Journal Line"; var AllowDelete: Boolean)
    begin
        InsertDeletedJobJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contrato Journal", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventJobJournal(var Rec: Record "Contrato Journal Line"; var xRec: Record "Contrato Journal Line"; var AllowModify: Boolean)
    begin
        SetJobJnlLineOnModify(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contrato Journal", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertRecordEventJobJournal(var Rec: Record "Contrato Journal Line"; var xRec: Record "Contrato Journal Line"; var AllowInsert: Boolean)
    begin
        SetJobJnlLineOnModify(Rec);
    end;
}
