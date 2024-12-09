codeunit 50226 "Contrato Jnl.-Post"
{
    TableNo = "Contrato Journal Line";
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        ContratoJnlLine.Copy(Rec);
        Code();
        Rec.Copy(ContratoJnlLine);
    end;

    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlLine: Record "Contrato Journal Line";
        JournalErrorsMgt: Codeunit "Journal Errors Mgt.";
        TempJnlBatchName: Code[10];
        HideDialog: Boolean;
        SuppressCommit: Boolean;
        PreviewMode: Boolean;

        Text000: Label 'cannot be filtered when posting recurring journals.';
        Text001: Label 'Do you want to post the journal lines?';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. ';
        Text005: Label 'You are now in the %1 journal.';

    local procedure "Code"()
    var
        ContratoJnlPostBatch: Codeunit "Contrato Jnl.-Post Batch";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        IsHandled: Boolean;
    begin
        OnBeforeCode(ContratoJnlLine, HideDialog, SuppressCommit);

        ContratoJnlTemplate.Get(ContratoJnlLine."Journal Template Name");
        ContratoJnlTemplate.TestField("Force Posting Report", false);
        if ContratoJnlTemplate.Recurring and (ContratoJnlLine.GetFilter("Posting Date") <> '') then
            ContratoJnlLine.FieldError("Posting Date", Text000);

        IsHandled := false;
        OnCodeOnBeforeConfirm(ContratoJnlLine, IsHandled);
        if not PreviewMode then
            if not IsHandled then
                if not Confirm(Text001) then
                    exit;

        OnCodeOnAfterConfirm(ContratoJnlLine);

        TempJnlBatchName := ContratoJnlLine."Journal Batch Name";

        ContratoJnlPostBatch.SetSuppressCommit(SuppressCommit or PreviewMode);
        ContratoJnlPostBatch.Run(ContratoJnlLine);

        if PreviewMode then
            GenJnlPostPreview.ThrowError();

        if not HideDialog then
            if ContratoJnlLine."Line No." = 0 then
                Message(JournalErrorsMgt.GetNothingToPostErrorMsg())
            else
                if TempJnlBatchName = ContratoJnlLine."Journal Batch Name" then
                    Message(Text003)
                else
                    Message(
                        Text004 +
                        Text005,
                        ContratoJnlLine."Journal Batch Name");

        if not ContratoJnlLine.Find('=><') or (TempJnlBatchName <> ContratoJnlLine."Journal Batch Name") then begin
            ContratoJnlLine.Reset();
            ContratoJnlLine.FilterGroup(2);
            ContratoJnlLine.SetRange("Journal Template Name", ContratoJnlLine."Journal Template Name");
            ContratoJnlLine.SetRange("Journal Batch Name", ContratoJnlLine."Journal Batch Name");
            ContratoJnlLine.FilterGroup(0);
            ContratoJnlLine."Line No." := 1;
        end;
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    internal procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    internal procedure Preview(var ContratoJournalLine: Record "Contrato Journal Line")
    var
        ContratoJnlPost: Codeunit "Contrato Jnl.-Post";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(ContratoJnlPost);
        GenJnlPostPreview.Preview(ContratoJnlPost, ContratoJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        ContratoJournalLine: Record "Contrato Journal Line";
        ContratoJnlPost: Codeunit "Contrato Jnl.-Post";
    begin
        ContratoJournalLine.Copy(RecVar);
        ContratoJnlPost.SetPreviewMode(true);
        Result := ContratoJnlPost.Run(ContratoJournalLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var ContratoJnlLine: Record "Contrato Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterConfirm(var ContratoJnlLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeConfirm(ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;
}

