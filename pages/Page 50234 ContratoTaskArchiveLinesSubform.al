page 50234 "ContrTaskArchiveLinesSubform"
{
    Caption = 'contrato Task Lines Subform';
    DataCaptionFields = "Contrato No.";
    PageType = ListPart;
    Editable = false;
    SourceTable = "Contrato Task Archive";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Contrato No."; Rec."Contrato No.")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related contrato.';
                    Visible = false;
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related contrato task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies a description of the contrato task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the contrato planning line.';
                }
                field("Contrato Task Type"; Rec."Contrato Task Type")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an interval or a list of contrato task numbers.';
                    Visible = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default for the contrato task.';
                    Visible = PerTaskBillingFieldsVisible;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who pays for the contrato task.';
                    Visible = PerTaskBillingFieldsVisible;
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the contrato posting group of the task.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code of the task.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a bin code for specific location of the task.';
                    Visible = false;
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the contrato tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                    Visible = false;
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the Work in Process calculation method that is associated with a contrato. The value in this field comes from the WIP method specified on the contrato card.';
                    Visible = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies the start date for the contrato task. The date is based on the date on the related contrato planning line.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies the end date for the contrato task. The date is based on the date on the related contrato planning line.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Caption = 'Budget (Total Cost)';
                    ToolTip = 'Specifies, in the local currency, the total budgeted cost for the contrato task during the time period in the Planning Date Filter field.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = Suite;
                    Caption = 'Budget (Total Price)';
                    ToolTip = 'Specifies, in local currency, the total budgeted price for the contrato task during the time period in the Planning Date Filter field.';
                    Visible = false;
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies, in local currency, the total cost of the usage of items, resources and general ledger expenses posted on the contrato task during the time period in the Posting Date Filter field.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in the local currency, the total price of the usage of items, resources and general ledger expenses posted on the contrato task during the time period in the Posting Date Filter field.';
                    Visible = false;
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in local currency, the total billable cost for the contrato task during the time period in the Planning Date Filter field.';
                    Visible = false;
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the contrato task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in the local currency, the total billable cost for the contrato task that has been invoiced during the time period in the Posting Date Filter field.';
                    Visible = false;
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the contrato task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the remaining total cost (LCY) as the sum of costs from contrato planning lines associated with the contrato task. The calculation occurs when you have specified that there is a usage link between the contrato ledger and the contrato planning lines.';
                    Visible = false;
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the remaining total price (LCY) as the sum of prices from contrato planning lines associated with the contrato task. The calculation occurs when you have specified that there is a usage link between the contrato ledger and the contrato planning lines.';
                    Visible = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Visible = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Visible = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                Caption = 'Line';
                group("&Contrato")
                {
                    Caption = '&contrato';
                    Image = Job;
                    action(ContratoPlanningLines)
                    {
                        ApplicationArea = All;
                        Caption = 'contrato &Planning Lines';
                        Image = JobLines;
                        Scope = Repeater;
                        ToolTip = 'View all planning lines for the contrato. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a contrato (budget) or you can specify what you actually agreed with your customer that he should pay for the contrato (billable).';

                        trigger OnAction()
                        var
                            ContratoPlanningLineArchive: Record "Contrato Planning Line Archive";
                            ContratoPlanningArchiveLines: Page "ContratoPlanningArchiveLines";
                        begin
                            Rec.TestField("Contrato No.");
                            ContratoPlanningLineArchive.FilterGroup(2);
                            ContratoPlanningLineArchive.SetRange("Contrato No.", Rec."Contrato No.");
                            ContratoPlanningLineArchive.SetRange("Contrato Task No.", Rec."Contrato Task No.");
                            ContratoPlanningLineArchive.SetRange("Version No.", Rec."Version No.");
                            ContratoPlanningLineArchive.FilterGroup(0);
                            ContratoPlanningArchiveLines.SetTableView(ContratoPlanningLineArchive);
                            ContratoPlanningArchiveLines.Editable := true;
                            ContratoPlanningArchiveLines.Run();
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := Rec.Indentation;
        StyleIsStrong := Rec."Contrato Task Type" <> "Contrato Task Type"::Posting;
    end;

    trigger OnOpenPage()
    var
        ContratoArchive: Record "Contrato Archive";
    begin
        if ContratoArchive.Get(Rec."Contrato No.") then
            PerTaskBillingFieldsVisible := ContratoArchive."Task Billing Method" = ContratoArchive."Task Billing Method"::"Multiple customers";
    end;

    trigger OnInit()
    begin
        PerTaskBillingFieldsVisible := false;
    end;

    var
        DescriptionIndent: Integer;
        StyleIsStrong: Boolean;
        PerTaskBillingFieldsVisible: Boolean;
}

