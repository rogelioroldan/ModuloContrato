page 50206 "Contrato Task Lines Subform"
{
    Caption = 'Contrato Task Lines Subform';
    DataCaptionFields = "Job No.";
    PageType = ListPart;
    SaveValues = true;
    CardPageId = "Contrato Task Card";
    SourceTable = "Contrato Task";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Contrato No."; Rec."Job No.")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related project.';
                    Visible = false;
                }
                field("Contrato Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related project task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies a description of the project task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the project planning line.';
                }
                field("Contrato Task Type"; Rec."Job Task Type")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';

                    trigger OnValidate()
                    begin
                        StyleIsStrong := Rec."Job Task Type" <> Rec."Job Task Type"::Posting;
                        CurrPage.Update();
                    end;
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an interval or a list of project task numbers.';
                    Visible = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default for the project task.';
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PostingTypeRow;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the customer who pays for the project task.';
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PostingTypeRow;
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the project posting group of the task.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the location code of the task.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a bin code for specific location of the task.';
                    Visible = false;
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the project tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                    Visible = false;
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the Work in Process calculation method that is associated with a project. The value in this field comes from the WIP method specified on the project card.';
                    Visible = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    ToolTip = 'Specifies the start date for the project task. The date is based on the date on the related project planning line.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    ToolTip = 'Specifies the end date for the project task. The date is based on the date on the related project planning line.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    Caption = 'Budget (Total Cost)';
                    ToolTip = 'Specifies, in the local currency, the total budgeted cost for the project task during the time period in the Planning Date Filter field.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = Suite;
                    Caption = 'Budget (Total Price)';
                    ToolTip = 'Specifies, in local currency, the total budgeted price for the project task during the time period in the Planning Date Filter field.';
                    Visible = false;
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    ToolTip = 'Specifies, in local currency, the total cost of the usage of items, resources and general ledger expenses posted on the project task during the time period in the Posting Date Filter field.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in the local currency, the total price of the usage of items, resources and general ledger expenses posted on the project task during the time period in the Posting Date Filter field.';
                    Visible = false;
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in local currency, the total billable cost for the project task during the time period in the Planning Date Filter field.';
                    Visible = false;
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the project task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in the local currency, the total billable cost for the project task that has been invoiced during the time period in the Posting Date Filter field.';
                    Visible = false;
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = Basic, Suite, Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the project task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the remaining total cost (LCY) as the sum of costs from project planning lines associated with the project task. The calculation occurs when you have specified that there is a usage link between the project ledger and the project planning lines.';
                    Visible = false;
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the remaining total price (LCY) as the sum of prices from project planning lines associated with the project task. The calculation occurs when you have specified that there is a usage link between the project ledger and the project planning lines.';
                    Visible = false;
                }
                field("EAC (Total Cost)"; Rec.CalcEACTotalCost())
                {
                    ApplicationArea = Suite;
                    Caption = 'EAC (Total Cost)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total cost for a project task line. If the Apply Usage Link check box on the project is selected, then the EAC (Total Cost) field is calculated as follows: Usage (Total Cost) + Remaining (Total Cost).';
                    Visible = false;
                }
                field("EAC (Total Price)"; Rec.CalcEACTotalPrice())
                {
                    ApplicationArea = Suite;
                    Caption = 'EAC (Total Price)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total price for a project task line. If the Apply Usage Link check box on the project is selected, then the EAC (Total Price) field is calculated as follows: Usage (Total Price) + Remaining (Total Price).';
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
                    ApplicationArea = Jobs;
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = Jobs;
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
                field("Outstanding Orders"; Rec."Outstanding Orders")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the sum of outstanding orders, in local currency, for this project task. The value of the Outstanding Amount (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        //OnBeforeOnDrillDownOutstandingOrders(Rec, IsHandled);
                        if IsHandled then
                            exit;

                        Rec.ApplyPurchaseLineFilters(PurchLine, Rec."Job No.", Rec."Job Task No.");
                        PurchLine.SetFilter("Outstanding Amount (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
                field("Amt. Rcd. Not Invoiced"; Rec."Amt. Rcd. Not Invoiced")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the sum for items that have been received but have not yet been invoiced. The value in the Amt. Rcd. Not Invoiced (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        //OnBeforeOnDrillDownAmtRcdNotInvoiced(Rec, IsHandled);
                        if IsHandled then
                            exit;

                        Rec.ApplyPurchaseLineFilters(PurchLine, Rec."Job No.", Rec."Job Task No.");
                        PurchLine.SetFilter("Amt. Rcd. Not Invoiced (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
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
                    Caption = '&Contrato';
                    Image = Job;
                    action(ContratoPlanningLines)
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Contrato &Planning Lines';
                        Image = JobLines;
                        Scope = Repeater;
                        ToolTip = 'View all planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (budget) or you can specify what you actually agreed with your customer that he should pay for the project (billable).';

                        trigger OnAction()
                        var
                            JobPlanningLine: Record "Contrato Planning Line";
                            JobPlanningLines: Page "Contrato Planning Lines";
                            IsHandled: Boolean;
                        begin
                            IsHandled := false;
                            //OnBeforeOnActionJobPlanningLines(Rec, IsHandled);
                            if IsHandled then
                                exit;
                            Rec.TestField("Job No.");
                            JobPlanningLine.FilterGroup(2);
                            JobPlanningLine.SetRange("Job No.", Rec."Job No.");
                            JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
                            JobPlanningLine.FilterGroup(0);
                            JobPlanningLines.SetTableView(JobPlanningLine);
                            JobPlanningLines.Editable := true;
                            JobPlanningLines.Run();
                        end;
                    }
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    ShowAs = SplitButton;

                    action("Dimensions-&Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Contrato Task Dimensions";
                        RunPageLink = "Job No." = field("Job No."),
                                      "Job Task No." = field("Job Task No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            JobTask: Record "Contrato Task";
                            JobTaskDimensionsMultiple: Page ContratoTaskDimensionsMultiple;
                        begin
                            CurrPage.SetSelectionFilter(JobTask);
                            JobTaskDimensionsMultiple.SetMultiJobTask(JobTask);
                            JobTaskDimensionsMultiple.RunModal();
                        end;
                    }
                }
                group(Documents)
                {
                    Caption = 'Documents';
                    Image = Invoice;
                    action("Create &Sales Invoice")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Create &Sales Invoice';
                        Ellipsis = true;
                        Image = JobSalesInvoice;
                        ToolTip = 'Use a batch job to help you create sales invoices for the involved project tasks.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            JobTask: Record "Contrato Task";
                        begin
                            Rec.TestField("Job No.");
                            Contrato.Get(Rec."Job No.");
                            // if Contrato.Blocked = Contrato.Blocked::All then
                            //     Contrato.TestBlocked();

                            JobTask.SetRange("Job No.", Contrato."No.");
                            if Rec."Job Task No." <> '' then
                                JobTask.SetRange("Job Task No.", Rec."Job Task No.");

                            REPORT.RunModal(REPORT::"Job Create Sales Invoice", true, false, JobTask);
                        end;
                    }
                    action(SalesInvoicesCreditMemos)
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Sales &Invoices/Credit Memos';
                        Image = GetSourceDoc;
                        ToolTip = 'View sales invoices or sales credit memos that are related to the selected project task.';

                        trigger OnAction()
                        var
                            JobInvoices: Page "Contrato Invoices";
                        begin
                            //JobInvoices.SetPrJobTask(Rec);
                            JobInvoices.RunModal();
                        end;
                    }
                }
                group(History)
                {
                    Caption = 'History';
                    Image = History;
                    action("Contrato Ledger E&ntries")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Project Ledger E&ntries';
                        Image = JobLedger;
                        RunObject = Page "Contrato Ledger Entries";
                        RunPageLink = "Job No." = field("Job No."),
                                      "Job Task No." = field("Job Task No.");
                        RunPageView = sorting("Job No.", "Job Task No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the project ledger entries.';
                    }
                }
                group("F&unctions")
                {
                    Caption = 'F&unctions';
                    Image = "Action";
                    action("Split &Planning Lines")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Split &Planning Lines';
                        Ellipsis = true;
                        Image = Splitlines;
                        ToolTip = 'Split planning lines of type Budget and Billable into two separate planning lines: Budget and Billable.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            JobTask: Record "Contrato Task";
                        begin
                            Rec.TestField("Job No.");
                            Contrato.Get(Rec."Job No.");
                            // if Contrato.Blocked = Contrato.Blocked::All then
                            //     Contrato.TestBlocked();

                            Rec.TestField("Job Task No.");
                            JobTask.SetRange("Job No.", Contrato."No.");
                            JobTask.SetRange("Job Task No.", Rec."Job Task No.");

                            REPORT.RunModal(REPORT::"Job Split Planning Line", true, false, JobTask);
                        end;
                    }
                    action("Change &Dates")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Change &Dates';
                        Ellipsis = true;
                        Image = ChangeDate;
                        ToolTip = 'Use a batch job to help you move planning lines on a project from one date interval to another.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            JobTask: Record "Contrato Task";
                        begin
                            Rec.TestField("Job No.");
                            Contrato.Get(Rec."Job No.");
                            // if Contrato.Blocked = Contrato.Blocked::All then
                            //     Contrato.TestBlocked();

                            JobTask.SetRange("Job No.", Contrato."No.");
                            if Rec."Job Task No." <> '' then
                                JobTask.SetRange("Job Task No.", Rec."Job Task No.");

                            REPORT.RunModal(REPORT::"Change Job Dates", true, false, JobTask);
                        end;
                    }
                    action("<Action7>")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'I&ndent Project Tasks';
                        Image = Indent;
                        RunObject = Codeunit "Job Task-Indent";
                        ToolTip = 'Move the selected lines in one position to show that the tasks are subcategories of other tasks. Project tasks that are totaled are the ones that lie between one pair of corresponding Begin-Total and End-Total project tasks.';
                    }
                    group("&Copy")
                    {
                        Caption = '&Copy';
                        Image = Copy;
                        action("Copy Contrato Planning Lines &from...")
                        {
                            ApplicationArea = Jobs;
                            Caption = 'Copy Project Planning Lines &from...';
                            Ellipsis = true;
                            Image = CopyToTask;
                            ToolTip = 'Use a batch job to help you copy planning lines from one project task to another. You can copy from a project task within the project you are working with or from a project task linked to a different project.';

                            trigger OnAction()
                            var
                                CopyJobPlanningLines: Page "Copy Contrato Planning Lines";
                            begin
                                Rec.TestField("Job Task Type", Rec."Job Task Type"::Posting);
                                //CopyJobPlanningLines.SetToJobTask(Rec);
                                CopyJobPlanningLines.RunModal();
                            end;
                        }
                        action("Copy Contrato Planning Lines &to...")
                        {
                            ApplicationArea = Jobs;
                            Caption = 'Copy Project Planning Lines &to...';
                            Ellipsis = true;
                            Image = CopyFromTask;
                            ToolTip = 'Use a batch job to help you copy planning lines from one project task to another. You can copy from a project task within the project you are working with or from a project task linked to a different project.';

                            trigger OnAction()
                            var
                                CopyJobPlanningLines: Page "Copy Contrato Planning Lines";
                            begin
                                Rec.TestField("Job Task Type", "Job Task Type"::Posting);
                                //CopyJobPlanningLines.SetFromJobTask(Rec);
                                CopyJobPlanningLines.RunModal();
                            end;
                        }
                    }
                    group("<Action13>")
                    {
                        Caption = 'W&IP';
                        Image = WIP;
                        action("<Action48>")
                        {
                            ApplicationArea = Jobs;
                            Caption = '&Calculate WIP';
                            Ellipsis = true;
                            Image = CalculateWIP;
                            ToolTip = 'Run the Project Calculate WIP batch job.';

                            trigger OnAction()
                            var
                                Contrato: Record Contrato;
                            begin
                                Rec.TestField("Job No.");
                                Contrato.Get(Rec."Job No.");
                                Contrato.SetRange("No.", Contrato."No.");
                                REPORT.RunModal(REPORT::"Job Calculate WIP", true, false, Contrato);
                            end;
                        }
                        action("<Action49>")
                        {
                            ApplicationArea = Jobs;
                            Caption = '&Post WIP to G/L';
                            Ellipsis = true;
                            Image = PostOrder;
                            ShortCutKey = 'F9';
                            ToolTip = 'Run the Project Post WIP to G/L batch job.';

                            trigger OnAction()
                            var
                                Contrato: Record Contrato;
                            begin
                                Rec.TestField("Job No.");
                                Contrato.Get(Rec."Job No.");
                                Contrato.SetRange("No.", Contrato."No.");
                                REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Contrato);
                            end;
                        }
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := Rec.Indentation;
        StyleIsStrong := Rec."Job Task Type" <> "Job Task Type"::Posting;
        PostingTypeRow := Rec."Job Task Type" = "Job Task Type"::Posting;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ClearTempDim();
        StyleIsStrong := Rec."Job Task Type" <> "Job Task Type"::Posting;
        PostingTypeRow := Rec."Job Task Type" = "Job Task Type"::Posting;
    end;

    var
        DescriptionIndent: Integer;
        StyleIsStrong: Boolean;
        PerTaskBillingFieldsVisible: Boolean;
        PostingTypeRow: Boolean;
#if not CLEAN24
        RefreshCustomerControl: Boolean;
#endif

    procedure SetPerTaskBillingFieldsVisible(Visible: Boolean)
    begin
        PerTaskBillingFieldsVisible := Visible;
        CurrPage.Update(false);
    end;

#if not CLEAN24
    [Obsolete('Procedure is not used.', '24.0')]
    procedure SetRefreshCustomerControl(Refresh: Boolean)
    begin
        RefreshCustomerControl := Refresh;
    end;
#endif

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnActionJobPlanningLines(var JobTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownOutstandingOrders(var JobTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownAmtRcdNotInvoiced(var JobTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;
}

