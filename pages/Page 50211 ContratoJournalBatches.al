page 50211 "Contrato Journal Batches"
{
    Caption = 'Project Journal Batches';
    DataCaptionExpression = DataCaption();
    Editable = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Contrato Journal Batch";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the name of this project journal. You can enter a maximum of 10 characters, both numbers and letters.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies a description of this journal.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number series from which entry or record numbers are assigned to new entries or records.';
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the code for the number series that will be used to assign document numbers to ledger entries that are posted from this journal batch. To see the number series that have been set up in the No. Series table, choose the field.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                    Visible = true;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Journal")
            {
                ApplicationArea = Contratos;
                Caption = 'Edit Journal';
                Image = OpenJournal;
                ShortCutKey = 'Return';
                ToolTip = 'Open a journal based on the journal batch.';

                trigger OnAction()
                begin
                    ContratoJnlMgt.TemplateSelectionFromBatch(Rec);
                end;
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Test Report';
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        //ReportPrint.PrintContratoJnlBatch(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = Contratos;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    RunObject = Codeunit "Contrato Jnl.-B.Post";
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';
                }
                action("Post and &Print")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    RunObject = Codeunit "Contrato Jnl.-B.Post+Print";
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Edit Journal_Promoted"; "Edit Journal")
                {
                }
                group(Category_Posting)
                {
                    Caption = 'Posting';
                    ShowAs = SplitButton;

                    actionref("P&ost_Promoted"; "P&ost")
                    {
                    }
                    actionref("Post and &Print_Promoted"; "Post and &Print")
                    {
                    }
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetRange("Journal Template Name");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewBatch();
    end;

    trigger OnOpenPage()
    begin
        ContratoJnlMgt.OpenJnlBatch(Rec);
    end;

    var
        ReportPrint: Codeunit "Test Report-Print";
        ContratoJnlMgt: Codeunit ContratoJnlManagement;

    local procedure DataCaption(): Text[250]
    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
    begin
        if not CurrPage.LookupMode then
            if Rec.GetFilter("Journal Template Name") <> '' then
                if Rec.GetRangeMin("Journal Template Name") = Rec.GetRangeMax("Journal Template Name") then
                    if ContratoJnlTemplate.Get(Rec.GetRangeMin("Journal Template Name")) then
                        exit(ContratoJnlTemplate.Name + ' ' + ContratoJnlTemplate.Description);
    end;
}

