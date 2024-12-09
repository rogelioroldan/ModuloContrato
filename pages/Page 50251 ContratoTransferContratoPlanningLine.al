page 50251 "ContrTransferContrPlanningLine"
{
    Caption = 'Contrato Transfer Contrato Planning Line';
    PageType = StandardDialog;
    SaveValues = true;
    SourceTable = "Contrato Journal Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the posting date for the document.';
                }
                field(ContratoJournalTemplateName; ContratoJournalTemplateName)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato Journal Template';
                    Lookup = true;
                    TableRelation = "Contrato Journal Template".Name where("Page ID" = const(201),
                                                                       Recurring = const(false));
                    ToolTip = 'Specifies the journal template that is used for the Contrato journal.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectContratoJournalTemplate();
                    end;
                }
                field(ContratoJournalBatchName; ContratoJournalBatchName)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato Journal Batch';
                    Lookup = true;
                    TableRelation = "Contrato Journal Batch".Name where("Journal Template Name" = field(Name));
                    ToolTip = 'Specifies the journal batch that is used for the Contrato journal.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectContratoJournalBatch();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        InitializeValues();
    end;

    var
        ContratoJournalTemplateName: Code[10];
        ContratoJournalBatchName: Code[10];
        PostingDate: Date;

    procedure InitializeValues()
    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlBatch: Record "Contrato Journal Batch";
    begin
        PostingDate := WorkDate();

        ContratoJnlTemplate.SetRange("Page ID", PAGE::"Contrato Journal");
        ContratoJnlTemplate.SetRange(Recurring, false);

        if ContratoJnlTemplate.Count = 1 then begin
            ContratoJnlTemplate.FindFirst();
            ContratoJournalTemplateName := ContratoJnlTemplate.Name;

            ContratoJnlBatch.SetRange("Journal Template Name", ContratoJournalTemplateName);

            if ContratoJnlBatch.Count = 1 then begin
                ContratoJnlBatch.FindFirst();
                ContratoJournalBatchName := ContratoJnlBatch.Name;
            end;
        end;
    end;

    local procedure SelectContratoJournalTemplate()
    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlBatch: Record "Contrato Journal Batch";
    begin
        ContratoJnlTemplate.SetRange("Page ID", PAGE::"Contrato Journal");
        ContratoJnlTemplate.SetRange(Recurring, false);

        if PAGE.RunModal(0, ContratoJnlTemplate) = ACTION::LookupOK then begin
            ContratoJournalTemplateName := ContratoJnlTemplate.Name;

            ContratoJnlBatch.SetRange("Journal Template Name", ContratoJournalTemplateName);

            if ContratoJnlBatch.Count = 1 then begin
                ContratoJnlBatch.FindFirst();
                ContratoJournalBatchName := ContratoJnlBatch.Name;
            end else
                ContratoJournalBatchName := '';
        end;
    end;

    local procedure SelectContratoJournalBatch()
    var
        ContratoJnlBatch: Record "Contrato Journal Batch";
    begin
        ContratoJnlBatch.SetRange("Journal Template Name", ContratoJournalTemplateName);

        if PAGE.RunModal(0, ContratoJnlBatch) = ACTION::LookupOK then
            ContratoJournalBatchName := ContratoJnlBatch.Name;
    end;

    procedure GetPostingDate(): Date
    begin
        exit(PostingDate);
    end;

    procedure GetContratoJournalTemplateName(): Code[10]
    begin
        exit(ContratoJournalTemplateName);
    end;

    procedure GetContratoJournalBatchName(): Code[10]
    begin
        exit(ContratoJournalBatchName);
    end;
}

