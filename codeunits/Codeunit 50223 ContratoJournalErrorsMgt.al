codeunit 50223 "Contrato Journal Errors Mgt."
{
    SingleInstance = true;

    trigger OnRun()
    begin

    end;

    var
        TempErrorMessage: Record "Error Message" temporary;
        TempContratoJnlLineModified: Record "Contrato Journal Line" temporary;
        TempDeletedContratoJnlLine: Record "Contrato Journal Line" temporary;
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

    procedure SetContratoJnlLineOnModify(Rec: Record "Contrato Journal Line")
    begin
        if BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled() then
            SaveContratoJournalLineToBuffer(Rec, TempContratoJnlLineModified);
    end;

    local procedure SaveContratoJournalLineToBuffer(ContratoJournalLine: Record "Contrato Journal Line"; var BufferLine: Record "Contrato Journal Line" temporary)
    begin
        if BufferLine.Get(ContratoJournalLine."Journal Template Name", ContratoJournalLine."Journal Batch Name", ContratoJournalLine."Line No.") then begin
            BufferLine.TransferFields(ContratoJournalLine);
            BufferLine.Modify();
        end else begin
            BufferLine := ContratoJournalLine;
            BufferLine.Insert();
        end;
    end;

    procedure GetContratoJnlLinePreviousLineNo() PrevLineNo: Integer
    begin
        if TempContratoJnlLineModified.FindFirst() then begin
            PrevLineNo := TempContratoJnlLineModified."Line No.";
            if TempContratoJnlLineModified.Delete() then;
        end;
    end;

    procedure SetFullBatchCheck(NewFullBatchCheck: Boolean)
    begin
        FullBatchCheck := NewFullBatchCheck;
    end;

    procedure GetDeletedContratoJnlLine(var TempContratoJnlLine: Record "Contrato Journal Line" temporary; ClearBuffer: Boolean): Boolean
    begin
        if TempDeletedContratoJnlLine.FindSet() then begin
            repeat
                TempContratoJnlLine := TempDeletedContratoJnlLine;
                TempContratoJnlLine.Insert();
            until TempDeletedContratoJnlLine.Next() = 0;

            if ClearBuffer then
                TempDeletedContratoJnlLine.DeleteAll();
            exit(true);
        end;

        exit(false);
    end;

    procedure CollectContratoJnlCheckParameters(ContratoJnlLine: Record "Contrato Journal Line"; var ErrorHandlingParameters: Record "Error Handling Parameters")
    begin
        ErrorHandlingParameters."Journal Template Name" := ContratoJnlLine."Journal Template Name";
        ErrorHandlingParameters."Journal Batch Name" := ContratoJnlLine."Journal Batch Name";
        ErrorHandlingParameters."Line No." := ContratoJnlLine."Line No.";
        ErrorHandlingParameters."Full Batch Check" := FullBatchCheck;
        ErrorHandlingParameters."Previous Line No." := GetContratoJnlLinePreviousLineNo();
    end;

    procedure InsertDeletedContratoJnlLine(ContratoJnlLine: Record "Contrato Journal Line")
    begin
        if BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled() then begin
            TempDeletedContratoJnlLine := ContratoJnlLine;
            if TempDeletedContratoJnlLine.Insert() then;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contrato Journal", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteRecordEventContratoJournal(var Rec: Record "Contrato Journal Line"; var AllowDelete: Boolean)
    begin
        InsertDeletedContratoJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contrato Journal", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventContratoJournal(var Rec: Record "Contrato Journal Line"; var xRec: Record "Contrato Journal Line"; var AllowModify: Boolean)
    begin
        SetContratoJnlLineOnModify(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contrato Journal", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertRecordEventContratoJournal(var Rec: Record "Contrato Journal Line"; var xRec: Record "Contrato Journal Line"; var AllowInsert: Boolean)
    begin
        SetContratoJnlLineOnModify(Rec);
    end;
}
