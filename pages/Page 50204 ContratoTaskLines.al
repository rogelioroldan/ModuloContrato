
page 50204 "Contrato Task Lines"
{
    Caption = 'Contrato Task Lines';
    DataCaptionFields = "Contrato No.";
    PageType = List;
    SaveValues = true;
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
                field("Contrato No."; Rec."Contrato No.")
                {
                    ApplicationArea = Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related project.';
                    Visible = false;
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related project task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies a description of the project task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the project planning line.';
                }
                field("Contrato Task Type"; Rec."Contrato Task Type")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies an interval or a list of project task numbers.';
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the project posting group of the task.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the location code of the task.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a bin code for specific location of the task.';
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the project tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the name of the Work in Process calculation method that is associated with a project. The value in this field comes from the WIP method specified on the project card.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the start date for the project task. The date is based on the date on the related project planning line.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the end date for the project task. The date is based on the date on the related project planning line.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total budgeted cost for the project task during the time period in the Planning Date Filter field.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in local currency, the total budgeted price for the project task during the time period in the Planning Date Filter field.';
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in local currency, the total cost of the usage of items, resources and general ledger expenses posted on the project task during the time period in the Posting Date Filter field.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total price of the usage of items, resources and general ledger expenses posted on the project task during the time period in the Posting Date Filter field.';
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in local currency, the total billable cost for the project task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the project task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable cost for the project task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the project task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the remaining total cost (LCY) as the sum of costs from project planning lines associated with the project task. The calculation occurs when you have specified that there is a usage link between the project ledger and the project planning lines.';
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the remaining total price (LCY) as the sum of prices from project planning lines associated with the project task. The calculation occurs when you have specified that there is a usage link between the project ledger and the project planning lines.';
                }
                field("EAC (Total Cost)"; Rec.CalcEACTotalCost())
                {
                    ApplicationArea = Jobs;
                    Caption = 'EAC (Total Cost)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total cost for a project task line. If the Apply Usage Link check box on the project is selected, then the EAC (Total Cost) field is calculated as follows:  Usage (Total Cost) + Remaining (Total Cost).';
                }
                field("EAC (Total Price)"; Rec.CalcEACTotalPrice())
                {
                    ApplicationArea = Jobs;
                    Caption = 'EAC (Total Price)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total price for a project task line. If the Apply Usage Link check box on the project is selected, then the EAC (Total Price) field is calculated as follows: Usage (Total Price) + Remaining (Total Price).';
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
                field("Outstanding Orders"; Rec."Outstanding Orders")
                {
                    ApplicationArea = Jobs;
                    Editable = false;
                    ToolTip = 'Specifies the sum of outstanding orders, in local currency, for this project task. The value of the Outstanding Amount (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine, Rec."Contrato No.", Rec."Contrato Task No.");
                        PurchLine.SetFilter("Outstanding Amt. Ex. VAT (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
                field("Amt. Rcd. Not Invoiced"; Rec."Amt. Rcd. Not Invoiced")
                {
                    ApplicationArea = Jobs;
                    Editable = false;
                    ToolTip = 'Specifies the sum for items that have been received but have not yet been invoiced. The value in the Amt. Rcd. Not Invoiced (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine, Rec."Contrato No.", Rec."Contrato Task No.");
                        PurchLine.SetFilter("Amt. Rcd. Not Invoiced (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
#if not CLEAN25
                field("Coupled to Dataverse"; Rec."Coupled to Dataverse")
                {
                    ApplicationArea = Jobs;
                    Visible = false;
                    ToolTip = 'Specifies if the project task is coupled to an entity in Field Service.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';
                }
#endif
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
                Caption = '&Contrato Task';
                Image = Task;
                action(JobPlanningLines)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Contrato &Planning Lines';
                    Image = JobLines;
                    ToolTip = 'View all planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (budget) or you can specify what you actually agreed with your customer that they should pay for the project (billable).';

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Contrato Planning Line";
                        JobPlanningLines: Page "Contrato Planning Lines";
                    begin
                        Rec.TestField("Contrato Task Type", Rec."Contrato Task Type"::Posting);
                        Rec.TestField("Contrato No.");
                        Rec.TestField("Contrato Task No.");
                        JobPlanningLine.FilterGroup(2);
                        JobPlanningLine.SetRange("Contrato No.", Rec."Contrato No.");
                        JobPlanningLine.SetRange("Contrato Task No.", Rec."Contrato Task No.");
                        JobPlanningLine.FilterGroup(0);
                        JobPlanningLines.SetJobTaskNoVisible(false);
                        JobPlanningLines.SetTableView(JobPlanningLine);
                        JobPlanningLines.Run();
                    end;
                }
                action(JobTaskStatistics)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Contrato Task &Statistics';
                    Image = StatisticsDocument;
                    RunObject = Page "Contrato Task Statistics";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistics for the project task.';
                }
                action("Contrato &Task Card")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Contrato &Task Card';
                    Image = Task;
                    RunObject = Page "Contrato Task Card";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about a project task, such as the description of the task and the type, which can be either a heading, a posting, a begin-total, an end-total, or a total.';
                }
                separator("-")
                {
                    Caption = '-';
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    action("Dimensions-&Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Contrato Task Dimensions";
                        RunPageLink = "Contrato No." = field("Contrato No."),
                                      "Contrato Task No." = field("Contrato Task No.");
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
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("Sales &Invoices/Credit Memos")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Sales &Invoices/Credit Memos';
                    Image = GetSourceDoc;
                    ToolTip = 'View sales invoices or sales credit memos that are related to the selected project task.';

                    trigger OnAction()
                    var
                        JobInvoices: Page "Contrato Invoices";
                    begin
                        JobInvoices.SetPrJobTask(Rec);
                        JobInvoices.RunModal();
                    end;
                }
            }
            group("W&IP")
            {
                Caption = 'W&IP';
                Image = WIP;
                action("&WIP Entries")
                {
                    ApplicationArea = Jobs;
                    Caption = '&WIP Entries';
                    Image = WIPEntries;
                    RunObject = Page "Contrato WIP Entries";
                    RunPageLink = "Contrato No." = field("Contrato No.");
                    RunPageView = sorting("Contrato No.", "Contrato Posting Group", "WIP Posting Date");
                    ToolTip = 'View entries for the project that are posted as work in process.';
                }
                action("WIP &G/L Entries")
                {
                    ApplicationArea = Jobs;
                    Caption = 'WIP &G/L Entries';
                    Image = WIPLedger;
                    RunObject = Page "Contrato WIP G/L Entries";
                    RunPageLink = "Contrato No." = field("Contrato No.");
                    RunPageView = sorting("Contrato No.");
                    ToolTip = 'View the project''s WIP G/L entries.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Contrato Ledger E&ntries")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Contrato Ledger E&ntries';
                    Image = JobLedger;
                    RunObject = Page "Contrato Ledger Entries";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    RunPageView = sorting("Contrato No.", "Contrato Task No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the project ledger entries.';
                }
            }
#if not CLEAN25
            group(ActionGroupFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Visible = false;
                ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';

                action(CRMGoToProduct)
                {
                    ApplicationArea = Suite;
                    Caption = 'Contrato Task in Field Service';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service entity.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RecordId);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send updated data to Dynamics 365 Field Service.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.UpdateOneNow(Rec.RecordId);
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Field Service entity.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Field Service entity.';
                        ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '25.0';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(Rec.RecordId);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Field Service entity.';
                        ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '25.0';

                        trigger OnAction()
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(Rec.RecordId);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for this table.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
#endif
        }
        area(processing)
        {
            group("New Documents")
            {
                Caption = 'New Documents';
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
                        Rec.TestField("Contrato No.");
                        Contrato.Get(Rec."Contrato No.");
                        // if Contrato.Blocked = Contrato.Blocked::All then
                        //     Contrato.TestBlocked();

                        JobTask.SetRange("Contrato No.", Contrato."No.");
                        if Rec."Contrato Task No." <> '' then
                            JobTask.SetRange("Contrato Task No.", Rec."Contrato Task No.");

                        REPORT.RunModal(REPORT::"Job Create Sales Invoice", true, false, JobTask);
                    end;
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
                        Rec.TestField("Contrato No.");
                        Contrato.Get(Rec."Contrato No.");
                        // if Contrato.Blocked = Contrato.Blocked::All then
                        //     Contrato.TestBlocked();

                        Rec.TestField("Contrato Task No.");
                        JobTask.SetRange("Contrato No.", Contrato."No.");
                        JobTask.SetRange("Contrato Task No.", Rec."Contrato Task No.");

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
                        Rec.TestField("Contrato No.");
                        Contrato.Get(Rec."Contrato No.");
                        // if Contrato.Blocked = Contrato.Blocked::All then
                        //     Contrato.TestBlocked();

                        JobTask.SetRange("Contrato No.", Contrato."No.");
                        if Rec."Contrato Task No." <> '' then
                            JobTask.SetRange("Contrato Task No.", Rec."Contrato Task No.");

                        REPORT.RunModal(REPORT::"Change Job Dates", true, false, JobTask);
                    end;
                }
                action("<Action7>")
                {
                    ApplicationArea = Jobs;
                    Caption = 'I&ndent Contrato Tasks';
                    Image = Indent;
                    RunObject = Codeunit "Job Task-Indent";
                    ToolTip = 'Move the selected lines in one position to show that the tasks are subcategories of other tasks. Contrato tasks that are totaled are the ones that lie between one pair of corresponding Begin-Total and End-Total project tasks.';
                }
                group("&Copy")
                {
                    Caption = '&Copy';
                    Image = Copy;
                    action("Copy Contrato Planning Lines &from...")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Copy Contrato Planning Lines &from...';
                        Ellipsis = true;
                        Image = CopyToTask;
                        ToolTip = 'Use a batch job to help you copy planning lines from one project task to another. You can copy from a project task within the project you are working with or from a project task linked to a different project.';

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Contrato Planning Lines";
                        begin
                            Rec.TestField("Contrato Task Type", Rec."Contrato Task Type"::Posting);
                            CopyJobPlanningLines.SetToJobTask(Rec);
                            CopyJobPlanningLines.RunModal();
                        end;
                    }
                    action("Copy Contrato Planning Lines &to...")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Copy Contrato Planning Lines &to...';
                        Ellipsis = true;
                        Image = CopyFromTask;
                        ToolTip = 'Use a batch job to help you copy planning lines from one project task to another. You can copy from a project task within the project you are working with or from a project task linked to a different project.';

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Contrato Planning Lines";
                        begin
                            Rec.TestField("Contrato Task Type", Rec."Contrato Task Type"::Posting);
                            CopyJobPlanningLines.SetFromJobTask(Rec);
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
                        ToolTip = 'Run the Contrato Calculate WIP batch job.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            JobCalculateWIP: Report "Job Calculate WIP";
                        begin
                            Rec.TestField("Contrato No.");
                            Contrato.Get(Rec."Contrato No.");
                            Contrato.SetRange("No.", Contrato."No.");
                            Clear(JobCalculateWIP);
                            JobCalculateWIP.SetTableView(Contrato);
                            JobCalculateWIP.Run();
                        end;
                    }
                    action("<Action49>")
                    {
                        ApplicationArea = Jobs;
                        Caption = '&Post WIP to G/L';
                        Ellipsis = true;
                        Image = PostOrder;
                        ShortCutKey = 'F9';
                        ToolTip = 'Run the Contrato Post WIP to G/L batch job.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                        begin
                            Rec.TestField("Contrato No.");
                            Contrato.Get(Rec."Contrato No.");
                            Contrato.SetRange("No.", Contrato."No.");
                            REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Contrato);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Contrato Actual to Budget (Cost)")
            {
                ApplicationArea = Jobs;
                Caption = 'Contrato Actual to Budget (Cost)';
                Image = "Report";
                RunObject = Report "Job Actual to Budget (Cost)";
                ToolTip = 'Compare budgeted and usage amounts for selected projects. All lines of the selected project show quantity, total cost, and line amount.';
            }
            action("Contrato Actual to Budget (Price)")
            {
                ApplicationArea = Jobs;
                Caption = 'Contrato Actual to Budget (Price)';
                Image = "Report";
                RunObject = Report "Job Actual to Budget (Price)";
                ToolTip = 'Compare the actual price of your projects to the price that was budgeted. The report shows budget and actual amounts for each phase, task, and steps.';
            }
            action("Contrato Analysis")
            {
                ApplicationArea = Jobs;
                Caption = 'Contrato Analysis';
                Image = "Report";
                RunObject = Report "Job Analysis";
                ToolTip = 'Analyze the project, such as the budgeted prices, usage prices, and billable prices, and then compares the three sets of prices.';
            }
            action("Contrato - Planning Lines")
            {
                ApplicationArea = Jobs;
                Caption = 'Contrato - Planning Lines';
                Image = "Report";
                RunObject = Report "Job - Planning Lines";
                ToolTip = 'View all planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (budget) or you can specify what you actually agreed with your customer that he should pay for the project (billable).';
            }
            action("Contrato - Suggested Billing")
            {
                ApplicationArea = Jobs;
                Caption = 'Contrato - Suggested Billing';
                Image = "Report";
                RunObject = Report "Job Cost Suggested Billing";
                ToolTip = 'View a list of all projects, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
            }
            action("Jobs - Transaction Detail")
            {
                ApplicationArea = Jobs;
                Caption = 'Projects - Transaction Detail';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Job - Transaction Detail";
                ToolTip = 'View all postings with entries for a selected project for a selected period, which have been charged to a certain project. At the end of each project list, the amounts are totaled separately for the Sales and Usage entry types.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                group("Category_Copy Lines")
                {
                    Caption = 'Copy Lines';

                    actionref("Copy Contrato Planning Lines &from..._Promoted"; "Copy Contrato Planning Lines &from...")
                    {
                    }
                    actionref("Copy Contrato Planning Lines &to..._Promoted"; "Copy Contrato Planning Lines &to...")
                    {
                    }
                }
                actionref("Create &Sales Invoice_Promoted"; "Create &Sales Invoice")
                {
                }
                actionref("Split &Planning Lines_Promoted"; "Split &Planning Lines")
                {
                }
            }
            group("Category_Job Task")
            {
                Caption = 'Contrato Task';

                actionref(JobPlanningLines_Promoted; JobPlanningLines)
                {
                }
                actionref("Sales &Invoices/Credit Memos_Promoted"; "Sales &Invoices/Credit Memos")
                {
                }
                group(Category_Dimensions)
                {
                    Caption = 'Dimensions';
                    ShowAs = SplitButton;

                    actionref("Dimensions-&Multiple_Promoted"; "Dimensions-&Multiple")
                    {
                    }
                    actionref("Dimensions-&Single_Promoted"; "Dimensions-&Single")
                    {
                    }
                }
                actionref(JobTaskStatistics_Promoted; JobTaskStatistics)
                {
                }
                actionref("Contrato &Task Card_Promoted"; "Contrato &Task Card")
                {
                }
            }
            group(Category_WIP)
            {
                Caption = 'WIP';

                actionref("<Action48>_Promoted"; "<Action48>")
                {
                }
                actionref("<Action49>_Promoted"; "<Action49>")
                {
                }
                actionref("&WIP Entries_Promoted"; "&WIP Entries")
                {
                }
                actionref("WIP &G/L Entries_Promoted"; "WIP &G/L Entries")
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Reports';

                actionref("Contrato - Planning Lines_Promoted"; "Contrato - Planning Lines")
                {
                }
                actionref("Contrato Actual to Budget (Cost)_Promoted"; "Contrato Actual to Budget (Cost)")
                {
                }
                actionref("Contrato Actual to Budget (Price)_Promoted"; "Contrato Actual to Budget (Price)")
                {
                }
                actionref("Contrato Analysis_Promoted"; "Contrato Analysis")
                {
                }
                actionref("Contrato - Suggested Billing_Promoted"; "Contrato - Suggested Billing")
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ClearTempDim();
    end;

    var
        DescriptionIndent: Integer;
        StyleIsStrong: Boolean;

    procedure SetPurchLineFilters(var PurchLine: Record "Purchase Line"; JobNo: Code[20]; JobTaskNo: Code[20])
    begin
        Rec.ApplyPurchaseLineFilters(PurchLine, JobNo, JobTaskNo);
    end;
}