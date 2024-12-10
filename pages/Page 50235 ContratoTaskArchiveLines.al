page 50235 "Contrato Task Archive Lines"
{
    Caption = 'Project Task Lines';
    DataCaptionFields = "Contrato No.";
    PageType = List;
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
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related project.';
                    Visible = false;
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related project task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies a description of the project task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the project planning line.';
                }
                field("Contrato Task Type"; Rec."Contrato Task Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an interval or a list of project task numbers.';
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the project posting group of the task.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code of the task.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a bin code for specific location of the task.';
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the project tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Work in Process calculation method that is associated with a project. The value in this field comes from the WIP method specified on the project card.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date for the project task. The date is based on the date on the related project planning line.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date for the project task. The date is based on the date on the related project planning line.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in the local currency, the total budgeted cost for the project task during the time period in the Planning Date Filter field.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in local currency, the total budgeted price for the project task during the time period in the Planning Date Filter field.';
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in local currency, the total cost of the usage of items, resources and general ledger expenses posted on the project task during the time period in the Posting Date Filter field.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in the local currency, the total price of the usage of items, resources and general ledger expenses posted on the project task during the time period in the Posting Date Filter field.';
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in local currency, the total billable cost for the project task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the project task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in the local currency, the total billable cost for the project task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the project task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining total cost (LCY) as the sum of costs from project planning lines associated with the project task. The calculation occurs when you have specified that there is a usage link between the project ledger and the project planning lines.';
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining total price (LCY) as the sum of prices from project planning lines associated with the project task. The calculation occurs when you have specified that there is a usage link between the project ledger and the project planning lines.';
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
        area(navigation)
        {
            group("&Contrato Task")
            {
                Caption = '&Project Task';
                Image = Task;
                action(ContratoPlanningLines)
                {
                    ApplicationArea = All;
                    Caption = 'Project &Planning Lines';
                    Image = JobLines;
                    ToolTip = 'View all planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (budget) or you can specify what you actually agreed with your customer that they should pay for the project (billable).';

                    trigger OnAction()
                    var
                        ContratoPlanningLineArchive: Record "Contrato Planning Line Archive";
                        ContratoPlanningArchiveLines: Page "ContratoPlanningArchiveLines";
                    begin
                        Rec.TestField("Contrato Task Type", Rec."Contrato Task Type"::Posting);
                        Rec.TestField("Contrato No.");
                        Rec.TestField("Contrato Task No.");
                        ContratoPlanningLineArchive.FilterGroup(2);
                        ContratoPlanningLineArchive.SetRange("Contrato No.", Rec."Contrato No.");
                        ContratoPlanningLineArchive.SetRange("Contrato Task No.", Rec."Contrato Task No.");
                        ContratoPlanningLineArchive.SetRange("Version No.", Rec."Version No.");
                        ContratoPlanningLineArchive.FilterGroup(0);
                        ContratoPlanningArchiveLines.SetTableView(ContratoPlanningLineArchive);
                        ContratoPlanningArchiveLines.Run();
                    end;
                }
                action("Contrato &Task Card")
                {
                    ApplicationArea = All;
                    Caption = 'Project &Task Card';
                    Image = Task;
                    RunObject = Page "Contrato Task Card";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about a project task, such as the description of the task and the type, which can be either a heading, a posting, a begin-total, an end-total, or a total.';
                }
            }
        }
        area(Promoted)
        {
            group("Category_Contrato Task")
            {
                Caption = 'Project Task';

                actionref(ContratoPlanningLines_Promoted; ContratoPlanningLines)
                {
                }
                actionref("Contrato &Task Card_Promoted"; "Contrato &Task Card")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := Rec.Indentation;
        StyleIsStrong := Rec."Contrato Task Type" <> Rec."Contrato Task Type"::Posting;
    end;

    var
        DescriptionIndent: Integer;
        StyleIsStrong: Boolean;
}

