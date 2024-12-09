codeunit 50203 "Contrato Jnl.-B.Post"
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
        ContratoJnlPostbatch: Codeunit "Contrato Jnl.-Post Batch";
        JnlWithErrors: Boolean;
        IsHandled: Boolean;
        Text000: Label 'Do you want to post the journals?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"()
    begin
        ContratoJnlTemplate.Get(ContratoJnlBatch."Journal Template Name");
        ContratoJnlTemplate.TestField("Force Posting Report", false);

        IsHandled := false;
        OnCodeOnBeforeConfirm(IsHandled, ContratoJnlBatch, ContratoJnlTemplate);
        if not IsHandled then
            if not Confirm(Text000) then
                exit;

        ContratoJnlBatch.Find('-');
        repeat
            ContratoJnlLine."Journal Template Name" := ContratoJnlBatch."Journal Template Name";
            ContratoJnlLine."Journal Batch Name" := ContratoJnlBatch.Name;
            ContratoJnlLine."Line No." := 1;
            OnCodeOnBeforeContratoJnlPostBatchRun(ContratoJnlLine, ContratoJnlBatch);
            Clear(ContratoJnlPostbatch);
            if ContratoJnlPostbatch.Run(ContratoJnlLine) then
                ContratoJnlBatch.Mark(false)
            else begin
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
            ContratoJnlBatch.FilterGroup(2);
            ContratoJnlBatch.SetRange("Journal Template Name", ContratoJnlBatch."Journal Template Name");
            ContratoJnlBatch.FilterGroup(0);
            ContratoJnlBatch.Name := '';
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeContratoJnlPostBatchRun(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoJournalBatch: Record "Contrato Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeConfirm(var IsHandled: Boolean; ContratoJournalBatch: Record "Contrato Journal Batch"; ContratoJournalTemplate: Record "Contrato Journal Template")
    begin
    end;
}

