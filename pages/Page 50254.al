page 50254 "Contrato Queue Entry Card"
{
    Caption = 'Contrato Queue Entry Card';
    DataCaptionFields = "Object Type to Run", "Object Caption to Run";
    PageType = Card;
    SourceTable = "Contrato Queue Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = Rec.Status = Rec.Status::"On Hold";
                field("Object Type to Run"; Rec."Object Type to Run")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the type of the object, report or codeunit, that is to be run for the Contrato queue entry. After you specify a type, you then select an object ID of that type in the Object ID to Run field.';
                }
                field("Object ID to Run"; Rec."Object ID to Run")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ID of the object that is to be run for this Contrato. You can select an ID that is of the object type that you have specified in the Object Type to Run field.';
                }
                field("Object Caption to Run"; Rec."Object Caption to Run")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the object that is selected in the Object ID to Run field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a description of the Contrato queue entry. You can edit and update the description on the Contrato queue entry card. The description is also displayed in the Contrato Queue Entries window, but it cannot be updated there.';
                }
                field("Parameter String"; Rec."Parameter String")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies a text string that is used as a parameter by the Contrato queue when it is run.';
                }
                field("Contrato Queue Category Code"; Rec."Contrato Queue Category Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the code of the Contrato queue category to which the Contrato queue entry belongs. Choose the field to select a code from the list.';
                }
                field("Priority Within Category"; Rec."Priority Within Category")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the priority of the Contrato within the Contrato queue category. Only relevant when Contrato queue category code is specified.';
                    Enabled = (Rec."Contrato Queue Category Code" <> '');
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field("Maximum No. of Attempts to Run"; Rec."Maximum No. of Attempts to Run")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how many times a Contrato queue task should be rerun after a Contrato queue fails to run. This is useful for situations in which a task might be unresponsive. For example, a task might be unresponsive because it depends on an external resource that is not always available.';
                }
                field("Rerun Delay (sec.)"; Rec."Rerun Delay (sec.)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how many seconds to wait before re-running this Contrato queue task in the event of a failure.';
                }
                field("Last Ready State"; Rec."Last Ready State")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the date and time when the Contrato queue entry was last set to Ready and sent to the Contrato queue.';
                }
                field("Earliest Start Date/Time"; Rec."Earliest Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest date and time when the Contrato queue entry should be run. The format for the date and time must be month/day/year hour:minute, and then AM or PM. For example, 3/10/2021 12:00 AM.';
                }
                field("Expiration Date/Time"; Rec."Expiration Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the date and time when the Contrato queue entry is to expire, after which the Contrato queue entry will not be run.  The format for the date and time must be month/day/year hour:minute, and then AM or PM. For example, 3/10/2021 12:00 AM.';
                }
                field("Timeout"; Rec."Contrato Timeout")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum time that the Contrato queue entry is allowed to run.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the Contrato queue entry. When you create a Contrato queue entry, its status is set to On Hold. You can set the status to Ready and back to On Hold. Otherwise, status information in this field is updated automatically.';
                }
            }
            group("Report Parameters")
            {
                Caption = 'Report Parameters';
                Editable = Rec.Status = Rec.Status::"On Hold";
                Visible = Rec."Object Type to Run" = Rec."Object Type to Run"::Report;
                field("Report Request Page Options"; Rec."Report Request Page Options")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether options on the report request page have been set for scheduled report Contrato. If the check box is selected, then options have been set for the scheduled report.';
                }
                field("Report Output Type"; Rec."Report Output Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the output of the scheduled report.';
                }
                field("Printer Name"; Rec."Printer Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the printer to use to print the scheduled report.';
                }
            }
            group(Recurrence)
            {
                Caption = 'Recurrence';
                Editable = Rec.Status = Rec.Status::"On Hold";
                field("Recurring Contrato"; Rec."Recurring Contrato")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies if the Contrato queue entry is recurring. If the Recurring Contrato check box is selected, then the Contrato queue entry is recurring. If the check box is cleared, the Contrato queue entry is not recurring. After you specify that a Contrato queue entry is a recurring one, you must specify on which days of the week the Contrato queue entry is to run. Optionally, you can also specify a time of day for the Contrato to run and how many minutes should elapse between runs.';
                }
                field("Run on Mondays"; Rec."Run on Mondays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Mondays.';
                }
                field("Run on Tuesdays"; Rec."Run on Tuesdays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Tuesdays.';
                }
                field("Run on Wednesdays"; Rec."Run on Wednesdays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Wednesdays.';
                }
                field("Run on Thursdays"; Rec."Run on Thursdays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Thursdays.';
                }
                field("Run on Fridays"; Rec."Run on Fridays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Fridays.';
                }
                field("Run on Saturdays"; Rec."Run on Saturdays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Saturdays.';
                }
                field("Run on Sundays"; Rec."Run on Sundays")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the Contrato queue entry runs on Sundays.';
                }
                field("Next Run Date Formula"; Rec."Next Run Date Formula")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date formula that is used to calculate the next time the recurring Contrato queue entry will run. If you use a date formula, all other recurrence settings are cleared.';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Recurring Contrato" = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the earliest time of the day that the recurring Contrato queue entry is to be run.';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Recurring Contrato" = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the latest time of the day that the recurring Contrato queue entry is to be run.';
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Recurring Contrato" = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the minimum number of minutes that are to elapse between runs of a Contrato queue entry. The value cannot be less than one minute. This field only has meaning if the Contrato queue entry is set to be a recurring Contrato. If you use a no. of minutes between runs, the date formula setting is cleared.';
                }
                field("Inactivity Timeout Period"; Rec."Inactivity Timeout Period")
                {
                    ApplicationArea = Basic, Suite;
                    MinValue = 5;
                    ToolTip = 'Specifies the number of minutes that pass before a recurring Contrato that has the status On Hold With Inactivity Timeout is automatically restated. The value cannot be less than five minutes.';
                }
                label(Control33)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                    Caption = '';
                }
                label(Control31)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                    Caption = '';
                }
                label(Control22)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                    Caption = '';
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
            group("Contrato &Queue")
            {
                Caption = 'Contrato &Queue';
                Image = CheckList;
                action("Set Status to Ready")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set Status to Ready';
                    Image = ResetStatus;
                    ToolTip = 'Change the status of the entry.';
                    Enabled = not IsPendingApproval;

                    trigger OnAction()
                    var
                        SetStatustoReadyActivatedLbl: Label 'UserSecurityId %1 set the Status of the Contrato queue entry %2 to Ready.', Locked = true;
                    begin
                        if IsUserDelegated then begin
                            ContratoQueueManagement.SendForApproval(Rec);
                            CurrPage.Update(false);
                        end else begin
                            Rec.SetStatus(Rec.Status::Ready);
                            //Session.LogAuditMessage(StrSubstNo(SetStatustoReadyActivatedLbl, UserSecurityId(), Rec."Entry No."), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 3, 0);
                        end;
                    end;
                }
                action("Set On Hold")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set On Hold';
                    Image = Pause;
                    ToolTip = 'Change the status of the entry.';

                    trigger OnAction()
                    begin
                        Rec.SetStatus(Rec.Status::"On Hold");
                        RecallModifyOnlyWhenReadOnlyNotification();
                    end;
                }
                action("Show Error")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Error';
                    Image = Error;
                    ToolTip = 'Show the error message that has stopped the entry.';

                    trigger OnAction()
                    begin
                        Rec.ShowErrorMessage();
                    end;
                }
                action(Restart)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Restart';
                    Image = Start;
                    ToolTip = 'Stop and start the entry.';

                    trigger OnAction()
                    begin
                        Rec.Restart();
                    end;
                }
                action(RunInForeground)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Run once (foreground)';
                    Image = DebugNext;
                    ToolTip = 'Run a copy of this Contrato once in foreground.';

                    trigger OnAction()
                    var
                        ContratoQueueManagement: Codeunit "Contrato Queue Management";
                    begin
                        ContratoQueueManagement.RunContratoQueueEntryOnce(Rec);
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                Visible = IsUserDelegated;

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = not IsPendingApproval and IsUserDelegated;
                    Visible = IsUserDelegated;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the Contrato queue entry.';

                    trigger OnAction()
                    begin
                        ContratoQueueManagement.SendForApproval(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = IsPendingApproval and IsUserDelegated;
                    Visible = IsUserDelegated;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
                    begin
                        //ApprovalsMgmt.OnCancelJobQueueEntryApprovalRequest(Rec);
                        WorkflowWebhookManagement.FindAndCancel(Rec.RecordId);
                    end;
                }
            }
        }
        area(navigation)
        {
            group(Action12)
            {
                Caption = 'Contrato &Queue';
                Image = CheckList;
                action(LogEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Log Entries';
                    Image = Log;
                    RunObject = Page "Job Queue Log Entries";
                    RunPageLink = ID = field(ID);
                    ToolTip = 'View the Contrato queue log entries.';
                }
                action(ShowRecord)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Record';
                    Image = ViewDetails;
                    ToolTip = 'Show the record for the entry.';

                    trigger OnAction()
                    begin
                        Rec.LookupRecordToProcess();
                    end;
                }
                action(ReportRequestPage)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Report Request Page';
                    Enabled = Rec."Object Type to Run" = Rec."Object Type to Run"::Report;
                    Image = "Report";
                    ToolTip = 'Show the request page for the entry. If the entry is set up to run a processing-only report, the request page is blank.';

                    trigger OnAction()
                    begin
                        //Rec.RunReportRequestPage();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Set Status to Ready_Promoted"; "Set Status to Ready")
                {
                }
                actionref("Set On Hold_Promoted"; "Set On Hold")
                {
                }
                actionref(Restart_Promoted; Restart)
                {
                }
                actionref(RunInForeground_Promoted; RunInForeground)
                {
                }
                actionref("Show Error_Promoted"; "Show Error")
                {
                }
            }
            group(Category_Contrato_Queue)
            {
                Caption = 'Contrato Queue';

                actionref(ReportRequestPage_Promoted; ReportRequestPage)
                {
                }
                actionref(ShowRecord_Promoted; ShowRecord)
                {
                }
                actionref(LogEntries_Promoted; LogEntries)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';

            }
            group(Category_Approvals)
            {
                Caption = 'Approvals';

                actionref(SendApprovalRequest_Promoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequest_Promoted; CancelApprovalRequest)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        if CurrPage.Editable and not (Rec.Status in [Rec.Status::"On Hold", Rec.Status::"On Hold with Inactivity Timeout"]) then
            ShowModifyOnlyWhenReadOnlyNotification();

        if IsUserDelegated then
            IsPendingApproval := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId());
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ID := CreateGuid();
        Rec.Status := Rec.Status::"On Hold";

        // Until Modern Dev decided to support InitValue on Duration we have to do it this way.
        Rec."Contrato Timeout" := Rec.DefaultContratoTimeout();
    end;

    trigger OnOpenPage()
    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
    begin
        IsUserDelegated := AzureADGraphUser.IsUserDelegatedAdmin() or AzureADGraphUser.IsUserDelegatedHelpdesk();
    end;

    var
        ContratoQueueManagement: Codeunit "Contrato Queue Management";
        ChooseSetOnHoldMsg: Label 'To edit the Contrato queue entry, you must first choose the Set On Hold action.';
        SetOnHoldLbl: Label 'Set On Hold';
        ModifyOnlyWhenReadOnlyNotificationIdTxt: Label 'dfc885c0-9960-411a-b96f-5deeedc712dc', Locked = true;
        IsUserDelegated: Boolean;
        IsPendingApproval: Boolean;

    procedure GetChooseSetOnHoldMsg(): Text
    begin
        exit(ChooseSetOnHoldMsg);
    end;

    local procedure GetModifyOnlyWhenReadOnlyNotificationId(): Guid
    var
        ModifyOnlyWhenReadOnlyNotificationId: Guid;
    begin
        Evaluate(ModifyOnlyWhenReadOnlyNotificationId, ModifyOnlyWhenReadOnlyNotificationIdTxt);
        exit(ModifyOnlyWhenReadOnlyNotificationId);
    end;

    local procedure RecallModifyOnlyWhenReadOnlyNotification()
    var
        ModifyOnlyWhenReadOnlyNotification: Notification;
    begin
        ModifyOnlyWhenReadOnlyNotification.Id := GetModifyOnlyWhenReadOnlyNotificationId();
        ModifyOnlyWhenReadOnlyNotification.Recall();
    end;

    local procedure ShowModifyOnlyWhenReadOnlyNotification()
    var
        ModifyOnlyWhenReadOnlyNotification: Notification;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowModifyOnlyWhenReadOnlyNotification(Rec, IsHandled);
        if IsHandled then
            exit;

        ModifyOnlyWhenReadOnlyNotification.Id := GetModifyOnlyWhenReadOnlyNotificationId();
        ModifyOnlyWhenReadOnlyNotification.Message := GetChooseSetOnHoldMsg();
        ModifyOnlyWhenReadOnlyNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        ModifyOnlyWhenReadOnlyNotification.SetData(Rec.FieldName(ID), Rec.ID);
        ModifyOnlyWhenReadOnlyNotification.AddAction(SetOnHoldLbl, CODEUNIT::"Job Queue - Send Notification",
          'SetContratoQueueEntryStatusToOnHold');
        ModifyOnlyWhenReadOnlyNotification.Send();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowModifyOnlyWhenReadOnlyNotification(var ContratoQueueEntry: Record "Contrato Queue Entry"; var IsHandled: Boolean)
    begin
    end;
}

