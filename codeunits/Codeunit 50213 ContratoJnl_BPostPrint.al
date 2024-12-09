codeunit 50213 "Contrato Jnl.-B.Post+Print"
{
    TableNo = "Contrato Journal Batch";

    trigger OnRun()
    begin
        ContratoJnlBatch.Copy(Rec);
        Code();
        Rec.Copy(ContratoJnlBatch);
    end;

    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlBatch: Record "Contrato Journal Batch";
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoReg: Record "Contrato Register";
        ContratoJnlPostbatch: Codeunit "Contrato Jnl.-Post Batch";
        JnlWithErrors: Boolean;

        Text000: Label 'Do you want to post the journals and print the posting report?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"()
    var
        HideDialog: Boolean;
    begin
        ContratoJnlTemplate.Get(ContratoJnlBatch."Journal Template Name");
        ContratoJnlTemplate.TestField("Posting Report ID");

        HideDialog := false;
        OnBeforePostJournalBatch(ContratoJnlBatch, HideDialog);
        if not HideDialog then
            if not Confirm(Text000) then
                exit;

        ContratoJnlBatch.Find('-');
        repeat
            ContratoJnlLine."Journal Template Name" := ContratoJnlBatch."Journal Template Name";
            ContratoJnlLine."Journal Batch Name" := ContratoJnlBatch.Name;
            ContratoJnlLine."Line No." := 1;
            OnCodeOnBeforeContratoJnlPostBatchRun(ContratoJnlLine, ContratoJnlBatch);
            Clear(ContratoJnlPostbatch);
            if ContratoJnlPostbatch.Run(ContratoJnlLine) then begin
                ContratoJnlBatch.Mark(false);
                if ContratoReg.Get(ContratoJnlLine."Line No.") then begin
                    ContratoReg.SetRecFilter();
                    REPORT.Run(ContratoJnlTemplate."Posting Report ID", false, false, ContratoReg);
                end;
            end else begin
                ContratoJnlBatch.Mark(true);
                JnlWithErrors := true;
            end;
        until ContratoJnlBatch.Next() = 0;

        if not JnlWithErrors then
            Message(Text001)
        else
            Message(
                Text002 +
                Text003);

        if not ContratoJnlBatch.Find('=><') then begin
            ContratoJnlBatch.Reset();
            ContratoJnlBatch.Name := '';
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJournalBatch(var ContratoJournalBatch: Record "Contrato Journal Batch"; var HideDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeContratoJnlPostBatchRun(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoJournalBatch: Record "Contrato Journal Batch")
    begin
    end;
}

