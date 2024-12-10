page 50232 "Contrato Archive List"
{
    AdditionalSearchTerms = 'Projects, Projects List, Archive, Contratos Archives';
    ApplicationArea = All;
    Caption = 'Project Archives';
    CardPageID = "Contrato Archive Card";
    Editable = false;
    PageType = List;
    QueryCategory = 'Project Archive List';
    SourceTable = "Contrato Archive";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the version number of the archived document.';
                }
                field("Date Archived"; Rec."Date Archived")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date when the document was archived.';
                }
                field("Time Archived"; Rec."Time Archived")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies what time the document was archived.';
                }
                field("Archived By"; Rec."Archived By")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the user ID of the person who archived this document.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."Archived By");
                    end;
                }
                field("Interaction Exist"; Rec."Interaction Exist")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies that the archived document is linked to an interaction log entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the project.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who pays for the project.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a status for the current project. You can change the status for the project as it progresses. Final calculations can be made on completed projects.';
                }
                field("Person Responsible"; Rec."Person Responsible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the person responsible for the project. You can select a name from the list of resources available in the Resource List window. The name is copied from the No. field in the Resource table. You can choose the field to see a list of resources.';
                    Visible = false;
                }
                field("Next Invoice Date"; Rec."Next Invoice Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the next invoice date for the project.';
                    Visible = false;
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a project posting group code for a project. To see the available codes, choose the field.';
                    Visible = false;
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the additional name for the project. The field is used for searching purposes.';
                }
                field("Project Manager"; Rec."Project Manager")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the person assigned as the manager for this project.';
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
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
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Contrato")
            {
                Caption = '&Project';
                Image = Job;
                action("Contrato Task &Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Project Task &Lines';
                    Image = TaskList;
                    RunObject = Page "Contrato Task Archive Lines";
                    RunPageLink = "Contrato No." = field("No."), "Version No." = field("Version No.");
                    ToolTip = 'Plan how you want to set up your planning information. In this window you can specify the tasks involved in a project. To start planning a project or to post usage for a project, you must set up at least one project task.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet Archive";
                    RunPageLink = "Table Name" = const(Contrato),
                                  "No." = field("No."),
                                  "Version No." = field("Version No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Category5)
            {
                Caption = 'Project', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref("Co&mments_Promoted"; "Co&mments")
                {
                }
                actionref("Contrato Task &Lines_Promoted"; "Contrato Task &Lines")
                {
                }
            }
        }
    }
}

