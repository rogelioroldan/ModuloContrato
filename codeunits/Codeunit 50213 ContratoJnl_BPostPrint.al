codeunit 50213 "Contrato Jnl.-B.Post+Print"
{
    TableNo = "Contrato Journal Batch";

    trigger OnRun()
    begin
        JobJnlBatch.Copy(Rec);
        Code();
        Rec.Copy(JobJnlBatch);
    end;

    var
        JobJnlTemplate: Record "Contrato Journal Template";
        JobJnlBatch: Record "Contrato Journal Batch";
        JobJnlLine: Record "Contrato Journal Line";
        JobReg: Record "Contrato Register";
        JobJnlPostbatch: Codeunit "Contrato Jnl.-Post Batch";
        JnlWithErrors: Boolean;

        Text000: Label 'Do you want to post the journals and print the posting report?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"()
    var
        HideDialog: Boolean;
    begin
        JobJnlTemplate.Get(JobJnlBatch."Journal Template Name");
        JobJnlTemplate.TestField("Posting Report ID");

        HideDialog := false;
        OnBeforePostJournalBatch(JobJnlBatch, HideDialog);
        if not HideDialog then
            if not Confirm(Text000) then
                exit;

        JobJnlBatch.Find('-');
        repeat
            JobJnlLine."Journal Template Name" := JobJnlBatch."Journal Template Name";
            JobJnlLine."Journal Batch Name" := JobJnlBatch.Name;
            JobJnlLine."Line No." := 1;
            OnCodeOnBeforeJobJnlPostBatchRun(JobJnlLine, JobJnlBatch);
            Clear(JobJnlPostbatch);
            if JobJnlPostbatch.Run(JobJnlLine) then begin
                JobJnlBatch.Mark(false);
                if JobReg.Get(JobJnlLine."Line No.") then begin
                    JobReg.SetRecFilter();
                    REPORT.Run(JobJnlTemplate."Posting Report ID", false, false, JobReg);
                end;
            end else begin
                JobJnlBatch.Mark(true);
                JnlWithErrors := true;
            end;
        until JobJnlBatch.Next() = 0;

        if not JnlWithErrors then
            Message(Text001)
        else
            Message(
                Text002 +
                Text003);

        if not JobJnlBatch.Find('=><') then begin
            JobJnlBatch.Reset();
            JobJnlBatch.Name := '';
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJournalBatch(var JobJournalBatch: Record "Contrato Journal Batch"; var HideDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeJobJnlPostBatchRun(var JobJournalLine: Record "Contrato Journal Line"; var JobJournalBatch: Record "Contrato Journal Batch")
    begin
    end;
}

