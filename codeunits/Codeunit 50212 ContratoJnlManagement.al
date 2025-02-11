codeunit 50212 ContratoJnlManagement
{
    Permissions = TableData "Contrato Journal Template" = rimd,
                  TableData "Contrato Journal Batch" = rimd,
                  TableData "Contrato Entry No." = rimd;

    trigger OnRun()
    begin
    end;

    var
        LastContratoJnlLine: Record "Contrato Journal Line";
        OpenFromBatch: Boolean;

        Text000: Label 'contrato';
        Text001: Label 'contrato Journal';
        Text002: Label 'RECURRING';
        Text003: Label 'Recurring contrato Journal';
        Text004: Label 'DEFAULT';
        Text005: Label 'Default Journal';

    procedure TemplateSelection(PageID: Integer; RecurringJnl: Boolean; var ContratoJnlLine: Record "Contrato Journal Line"; var JnlSelected: Boolean)
    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
    begin
        JnlSelected := true;

        ContratoJnlTemplate.Reset();
        ContratoJnlTemplate.SetRange("Page ID", PageID);
        ContratoJnlTemplate.SetRange(Recurring, RecurringJnl);
        OnTemplateSelectionOnAfterContratoJnlTemplateSetFilters(PageID, RecurringJnl, ContratoJnlLine, ContratoJnlTemplate);
        case ContratoJnlTemplate.Count of
            0:
                begin
                    ContratoJnlTemplate.Init();
                    ContratoJnlTemplate.Recurring := RecurringJnl;
                    if not RecurringJnl then begin
                        ContratoJnlTemplate.Name := Text000;
                        ContratoJnlTemplate.Description := Text001;
                    end else begin
                        ContratoJnlTemplate.Name := Text002;
                        ContratoJnlTemplate.Description := Text003;
                    end;
                    ContratoJnlTemplate.Validate("Page ID");
                    ContratoJnlTemplate.Insert();
                    Commit();
                end;
            1:
                ContratoJnlTemplate.FindFirst();
            else
                JnlSelected := PAGE.RunModal(0, ContratoJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            ContratoJnlLine.FilterGroup := 2;
            ContratoJnlLine.SetRange("Journal Template Name", ContratoJnlTemplate.Name);
            ContratoJnlLine.FilterGroup := 0;
            if OpenFromBatch then begin
                ContratoJnlLine."Journal Template Name" := '';
                PAGE.Run(ContratoJnlTemplate."Page ID", ContratoJnlLine);
            end;
        end;
    end;

    procedure TemplateSelectionFromBatch(var ContratoJnlBatch: Record "Contrato Journal Batch")
    var
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoJnlTemplate: Record "Contrato Journal Template";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTemplateSelectionFromBatch(ContratoJnlBatch, OpenFromBatch, IsHandled);
        if IsHandled then
            exit;

        OpenFromBatch := true;
        ContratoJnlTemplate.Get(ContratoJnlBatch."Journal Template Name");
        ContratoJnlTemplate.TestField("Page ID");
        ContratoJnlBatch.TestField(Name);

        ContratoJnlLine.FilterGroup := 2;
        ContratoJnlLine.SetRange("Journal Template Name", ContratoJnlTemplate.Name);
        ContratoJnlLine.FilterGroup := 0;

        ContratoJnlLine."Journal Template Name" := '';
        ContratoJnlLine."Journal Batch Name" := ContratoJnlBatch.Name;
        PAGE.Run(ContratoJnlTemplate."Page ID", ContratoJnlLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    begin
        OnBeforeOpenJnl(CurrentJnlBatchName, ContratoJnlLine);

        CheckTemplateName(ContratoJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        ContratoJnlLine.FilterGroup := 2;
        ContratoJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        ContratoJnlLine.FilterGroup := 0;
    end;

    procedure OpenJnlBatch(var ContratoJnlBatch: Record "Contrato Journal Batch")
    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlLine: Record "Contrato Journal Line";
        JnlSelected: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenJnlBatch(ContratoJnlBatch, IsHandled);
        if IsHandled then
            exit;

        if ContratoJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        ContratoJnlBatch.FilterGroup(2);
        if ContratoJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            ContratoJnlBatch.FilterGroup(0);
            exit;
        end;
        ContratoJnlBatch.FilterGroup(0);

        if not ContratoJnlBatch.Find('-') then begin
            if not ContratoJnlTemplate.FindFirst() then
                TemplateSelection(0, false, ContratoJnlLine, JnlSelected);
            if ContratoJnlTemplate.FindFirst() then
                CheckTemplateName(ContratoJnlTemplate.Name, ContratoJnlBatch.Name);
            ContratoJnlTemplate.SetRange(Recurring, true);
            if not ContratoJnlTemplate.FindFirst() then
                TemplateSelection(0, true, ContratoJnlLine, JnlSelected);
            if ContratoJnlTemplate.FindFirst() then
                CheckTemplateName(ContratoJnlTemplate.Name, ContratoJnlBatch.Name);
            ContratoJnlTemplate.SetRange(Recurring);
        end;
        ContratoJnlBatch.Find('-');
        JnlSelected := true;
        ContratoJnlBatch.CalcFields(Recurring);
        ContratoJnlTemplate.SetRange(Recurring, ContratoJnlBatch.Recurring);
        if ContratoJnlBatch.GetFilter("Journal Template Name") <> '' then
            ContratoJnlTemplate.SetRange(Name, ContratoJnlBatch.GetFilter("Journal Template Name"));
        case ContratoJnlTemplate.Count of
            1:
                ContratoJnlTemplate.FindFirst();
            else
                JnlSelected := PAGE.RunModal(0, ContratoJnlTemplate) = ACTION::LookupOK;
        end;
        if not JnlSelected then
            Error('');

        ContratoJnlBatch.FilterGroup(0);
        ContratoJnlBatch.SetRange("Journal Template Name", ContratoJnlTemplate.Name);
        ContratoJnlBatch.FilterGroup(2);
    end;

    local procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        ContratoJnlBatch: Record "Contrato Journal Batch";
    begin
        ContratoJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if not ContratoJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if not ContratoJnlBatch.FindFirst() then begin
                ContratoJnlBatch.Init();
                ContratoJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                ContratoJnlBatch.SetupNewBatch();
                ContratoJnlBatch.Name := Text004;
                ContratoJnlBatch.Description := Text005;
                ContratoJnlBatch.Insert(true);
                Commit();
            end;
            CurrentJnlBatchName := ContratoJnlBatch.Name;
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    var
        ContratoJnlBatch: Record "Contrato Journal Batch";
    begin
        ContratoJnlBatch.Get(ContratoJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    begin
        ContratoJnlLine.FilterGroup := 2;
        ContratoJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        ContratoJnlLine.FilterGroup := 0;
        if ContratoJnlLine.Find('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    var
        ContratoJnlBatch: Record "Contrato Journal Batch";
    begin
        Commit();
        ContratoJnlBatch."Journal Template Name" := ContratoJnlLine.GetRangeMax("Journal Template Name");
        ContratoJnlBatch.Name := ContratoJnlLine.GetRangeMax("Journal Batch Name");
        ContratoJnlBatch.FilterGroup(2);
        ContratoJnlBatch.SetRange("Journal Template Name", ContratoJnlBatch."Journal Template Name");
        OnLookupNameOnAfterSetFilters(ContratoJnlBatch);
        ContratoJnlBatch.FilterGroup(0);
        if PAGE.RunModal(0, ContratoJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := ContratoJnlBatch.Name;
            SetName(CurrentJnlBatchName, ContratoJnlLine);
        end;
    end;

    procedure GetNames(var ContratoJnlLine: Record "Contrato Journal Line"; var ContratoDescription: Text[100]; var AccName: Text[100])
    var
        Res: Record Resource;
        Item: Record Item;
        GLAcc: Record "G/L Account";
    begin
        ContratoDescription := GetContratoDescription(ContratoJnlLine);

        if (ContratoJnlLine.Type <> LastContratoJnlLine.Type) or
           (ContratoJnlLine."No." <> LastContratoJnlLine."No.")
        then begin
            AccName := '';
            if ContratoJnlLine."No." <> '' then
                case ContratoJnlLine.Type of
                    ContratoJnlLine.Type::Resource:
                        if Res.Get(ContratoJnlLine."No.") then
                            AccName := Res.Name;
                    ContratoJnlLine.Type::Item:
                        if Item.Get(ContratoJnlLine."No.") then
                            AccName := Item.Description;
                    ContratoJnlLine.Type::"G/L Account":
                        if GLAcc.Get(ContratoJnlLine."No.") then
                            AccName := GLAcc.Name;
                end;
        end;

        LastContratoJnlLine := ContratoJnlLine;
    end;

    local procedure GetContratoDescription(ContratoJnlLine: Record "Contrato Journal Line") ContratoDescription: Text[100]
    var
        Contrato: Record Contrato;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetContratoDescription(ContratoJnlLine, LastContratoJnlLine, ContratoDescription, IsHandled);
        if IsHandled then
            exit(ContratoDescription);

        if (ContratoJnlLine."Contrato No." = '') or
           (ContratoJnlLine."Contrato No." <> LastContratoJnlLine."Contrato No.")
        then begin
            ContratoDescription := '';
            if Contrato.Get(ContratoJnlLine."Contrato No.") then
                ContratoDescription := Contrato.Description;
        end;
    end;

    procedure GetNextEntryNo(): Integer
    var
        ContratoEntryNo: Record "Contrato Entry No.";
    begin
        ContratoEntryNo.LockTable();
        if not ContratoEntryNo.Get() then
            ContratoEntryNo.Insert();
        ContratoEntryNo."Entry No." := ContratoEntryNo."Entry No." + 1;
        ContratoEntryNo.Modify();
        exit(ContratoEntryNo."Entry No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupNameOnAfterSetFilters(var ContratoJournalBatch: Record "Contrato Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenJnlBatch(var ContratoJournalBatch: Record "Contrato Journal Batch"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetContratoDescription(ContratoJnlLine: Record "Contrato Journal Line"; LastContratoJnlLine: Record "Contrato Journal Line"; var ContratoDescription: Text[100]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenJnl(var CurrentJnlBatchName: Code[10]; var ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTemplateSelectionFromBatch(var ContratoJnlBatch: Record "Contrato Journal Batch"; var OpenFromBatch: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTemplateSelectionOnAfterContratoJnlTemplateSetFilters(PageID: Integer; RecurringJnl: Boolean; var ContratoJnlLine: Record "Contrato Journal Line"; var ContratoJournalTemplate: Record "Contrato Journal Template")
    begin
    end;
}

