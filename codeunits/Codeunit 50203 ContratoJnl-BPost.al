codeunit 50203 "Contrato Jnl.-B.Post"
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
        JobJnlPostbatch: Codeunit "Contrato Jnl.-Post Batch";
        JnlWithErrors: Boolean;
        IsHandled: Boolean;
        Text000: Label 'Do you want to post the journals?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"()
    begin
        JobJnlTemplate.Get(JobJnlBatch."Journal Template Name");
        JobJnlTemplate.TestField("Force Posting Report", false);

        IsHandled := false;
        OnCodeOnBeforeConfirm(IsHandled, JobJnlBatch, JobJnlTemplate);
        if not IsHandled then
            if not Confirm(Text000) then
                exit;

        JobJnlBatch.Find('-');
        repeat
            JobJnlLine."Journal Template Name" := JobJnlBatch."Journal Template Name";
            JobJnlLine."Journal Batch Name" := JobJnlBatch.Name;
            JobJnlLine."Line No." := 1;
            OnCodeOnBeforeJobJnlPostBatchRun(JobJnlLine, JobJnlBatch);
            Clear(JobJnlPostbatch);
            if JobJnlPostbatch.Run(JobJnlLine) then
                JobJnlBatch.Mark(false)
            else begin
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
            JobJnlBatch.FilterGroup(2);
            JobJnlBatch.SetRange("Journal Template Name", JobJnlBatch."Journal Template Name");
            JobJnlBatch.FilterGroup(0);
            JobJnlBatch.Name := '';
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeJobJnlPostBatchRun(var JobJournalLine: Record "Contrato Journal Line"; var JobJournalBatch: Record "Contrato Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeConfirm(var IsHandled: Boolean; JobJournalBatch: Record "Contrato Journal Batch"; JobJournalTemplate: Record "Contrato Journal Template")
    begin
    end;
}

