namespace System.Threading;

using System.Automation;
using System.Utilities;
using System.Environment;
using System.Security.User;
using System.Telemetry;

codeunit 50235 "Contrato Queue Management"
{
    var
        TelemetrySubscribers: Codeunit "Telemetry Subscribers";
        RunOnceQst: label 'This will create a temporary non-recurrent copy of this Contrato and will run it once in the foreground.\Do you want to continue?';
        ExecuteBeginMsg: label 'Executing Contrato queue entry...';
        ExecuteEndSuccessMsg: label 'Contrato finished executing.\Status: %1', Comment = '%1 is a status value, e.g. Success';
        ExecuteEndErrorMsg: label 'Contrato finished executing.\Status: %1\Error: %2', Comment = '%1 is a status value, e.g. Success, %2=Error message';
        ContratoSomethingWentWrongMsg: Label 'Something went wrong and the Contrato has stopped. Likely causes are system updates or routine maintenance processes. To restart the Contrato, set the status to Ready.';
        ContratoQueueDelegatedAdminCategoryTxt: Label 'AL ContratoQueueEntries Delegated Admin', Locked = true;
        ContratoQueueStatusChangeTxt: Label 'The status for Contrato Queue Entry: %1 has changed.', Comment = '%1 is the Contrato Queue Entry Id', Locked = true;
        TelemetryStaleContratoQueueEntryTxt: Label 'Updated Contrato Queue Entry status to error as it is stale. Please investigate associated Task Id for error.', Locked = true;
        TelemetryStaleContratoQueueLogEntryTxt: Label 'Updated Contrato Queue Log Entry status to error as it is stale. Please investigate associated Task Id for error.', Locked = true;
        RunContratoQueueOnceTxt: Label 'Running Contrato queue once.', Locked = true;
        ContratoQueueWorkflowSetupErr: Label 'The Contrato Queue approval workflow has not been setup.';
        DelegatedAdminSendingApprovalLbl: Label 'Delegated admin sending approval', Locked = true;
        TooManyScheduledTasksLinkTxt: Label 'Learn more';
        TooManyScheduledTasksNotificationMsg: Label 'There are more than 100,000 scheduled tasks in the system. This can prevent Contrato Queues and tasks from running in a timely manner. Please contact your system administrator.';
        TooManyScheduledTasksNotificationGuidLbl: Label 'cedc5167-e04c-4127-b7dd-114d1749700a', Locked = true;

    trigger OnRun()
    begin
    end;

    internal procedure CheckUserInContratoQueueAdminList(UserName: Text): Boolean
    var
    //ContratoQueueAdminList: Record "Job Queue Notified Admin";
    begin
        //exit(ContratoQueueAdminList.Get(UserName));
    end;

    procedure CreateContratoQueueEntry(var ContratoQueueEntry: Record "Contrato Queue Entry")
    var
        EarliestStartDateTime: DateTime;
        ReportOutputType: Enum "Job Queue Report Output Type";
        ObjectTypeToRun: Option;
        ObjectIdToRun: Integer;
        NoOfMinutesBetweenRuns: Integer;
        RecurringContrato: Boolean;
    begin
        NoOfMinutesBetweenRuns := ContratoQueueEntry."No. of Minutes between Runs";
        EarliestStartDateTime := ContratoQueueEntry."Earliest Start Date/Time";
        ReportOutputType := ContratoQueueEntry."Report Output Type";
        ObjectTypeToRun := ContratoQueueEntry."Object Type to Run";
        ObjectIdToRun := ContratoQueueEntry."Object ID to Run";

        ContratoQueueEntry.SetRange("Object Type to Run", ObjectTypeToRun);
        ContratoQueueEntry.SetRange("Object ID to Run", ObjectIdToRun);
        if NoOfMinutesBetweenRuns <> 0 then
            RecurringContrato := true
        else
            RecurringContrato := false;
        ContratoQueueEntry.SetRange("Recurring Contrato", RecurringContrato);
        if not ContratoQueueEntry.IsEmpty() then
            exit;

        ContratoQueueEntry.Init();
        ContratoQueueEntry.Validate("Object Type to Run", ObjectTypeToRun);
        ContratoQueueEntry.Validate("Object ID to Run", ObjectIdToRun);
        ContratoQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
        if NoOfMinutesBetweenRuns <> 0 then begin
            ContratoQueueEntry.Validate("Run on Mondays", true);
            ContratoQueueEntry.Validate("Run on Tuesdays", true);
            ContratoQueueEntry.Validate("Run on Wednesdays", true);
            ContratoQueueEntry.Validate("Run on Thursdays", true);
            ContratoQueueEntry.Validate("Run on Fridays", true);
            ContratoQueueEntry.Validate("Run on Saturdays", true);
            ContratoQueueEntry.Validate("Run on Sundays", true);
            ContratoQueueEntry.Validate("Recurring Contrato", RecurringContrato);
            ContratoQueueEntry."No. of Minutes between Runs" := NoOfMinutesBetweenRuns;
        end;
        ContratoQueueEntry."Maximum No. of Attempts to Run" := 3;
        ContratoQueueEntry."Notify On Success" := true;
        ContratoQueueEntry.Status := ContratoQueueEntry.Status::"On Hold";
        ContratoQueueEntry."Earliest Start Date/Time" := EarliestStartDateTime;
        ContratoQueueEntry."Report Output Type" := ReportOutputType;
        ContratoQueueEntry.Insert(true);
    end;

    procedure DeleteContratoQueueEntries(ObjectTypeToDelete: Option; ObjectIdToDelete: Integer)
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
    begin
        ContratoQueueEntry.SetRange("Object Type to Run", ObjectTypeToDelete);
        ContratoQueueEntry.SetRange("Object ID to Run", ObjectIdToDelete);
        if ContratoQueueEntry.FindSet() then
            repeat
                if ContratoQueueEntry.Status = ContratoQueueEntry.Status::"In Process" then begin
                    // Non-recurring Contratos will be auto-deleted after execution has completed.
                    ContratoQueueEntry."Recurring Contrato" := false;
                    ContratoQueueEntry.Modify();
                end else
                    ContratoQueueEntry.Delete();
            until ContratoQueueEntry.Next() = 0;
    end;

    procedure StartInactiveContratoQueueEntries(ObjectTypeToStart: Option; ObjectIdToStart: Integer)
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
    begin
        ContratoQueueEntry.SetRange("Object Type to Run", ObjectTypeToStart);
        ContratoQueueEntry.SetRange("Object ID to Run", ObjectIdToStart);
        ContratoQueueEntry.SetRange(Status, ContratoQueueEntry.Status::"On Hold");
        if ContratoQueueEntry.FindSet() then
            repeat
                ContratoQueueEntry.SetStatus(ContratoQueueEntry.Status::Ready);
            until ContratoQueueEntry.Next() = 0;
    end;

    procedure SetContratoQueueEntriesOnHold(ObjectTypeToSetOnHold: Option; ObjectIdToSetOnHold: Integer)
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
    begin
        ContratoQueueEntry.SetRange("Object Type to Run", ObjectTypeToSetOnHold);
        ContratoQueueEntry.SetRange("Object ID to Run", ObjectIdToSetOnHold);
        if ContratoQueueEntry.FindSet() then
            repeat
                ContratoQueueEntry.SetStatus(ContratoQueueEntry.Status::"On Hold");
            until ContratoQueueEntry.Next() = 0;
    end;

    procedure SetRecurringContratosOnHold(CompanyName: Text)
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
    begin
        ContratoQueueEntry.ChangeCompany(CompanyName);
        ContratoQueueEntry.SetRange("Recurring Contrato", true);
        ContratoQueueEntry.SetRange(Status, ContratoQueueEntry.Status::Ready);
        if ContratoQueueEntry.FindSet(true) then
            repeat
                ContratoQueueEntry.Status := ContratoQueueEntry.Status::"On Hold";
                ContratoQueueEntry.Modify();
            until ContratoQueueEntry.Next() = 0;
    end;

    procedure SetStatusToOnHoldIfInstanceInactiveFor(PeriodType: Option Day,Week,Month,Quarter,Year; NoOfPeriods: Integer; ObjectTypeToSetOnHold: Option; ObjectIdToSetOnHold: Integer): Boolean
    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        PeriodFirstLetter: Text;
        FromDate: Date;
    begin
        PeriodFirstLetter := CopyStr(Format(PeriodType, 0, 0), 1, 1);
        FromDate := CalcDate(StrSubstNo('<-%1%2>', NoOfPeriods, PeriodFirstLetter));

        if not UserLoginTimeTracker.AnyUserLoggedInSinceDate(FromDate) then begin
            SetContratoQueueEntriesOnHold(ObjectTypeToSetOnHold, ObjectIdToSetOnHold);
            exit(true);
        end;

        exit(false);
    end;

    procedure RunContratoQueueEntryOnce(var SelectedContratoQueueEntry: Record "Contrato Queue Entry")
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
        ContratoQueueLogEntry: Record "Contrato Queue Log Entry";
        SuccessDispatcher: Boolean;
        SuccessErrorHandler: Boolean;
        Window: Dialog;
        CurrentLanguage: Integer;
        Dimensions: Dictionary of [Text, Text];
    begin
        if not Confirm(RunOnceQst, false) then
            exit;

        Window.Open(ExecuteBeginMsg);
        SelectedContratoQueueEntry.CalcFields(XML);
        ContratoQueueEntry := SelectedContratoQueueEntry;
        ContratoQueueEntry.ID := CreateGuid();
        ContratoQueueEntry."User ID" := copystr(UserId(), 1, MaxStrLen(ContratoQueueEntry."User ID"));
        ContratoQueueEntry."Recurring Contrato" := false;
        ContratoQueueEntry.Status := ContratoQueueEntry.Status::"Ready";
        ContratoQueueEntry."Contrato Queue Category Code" := '';
        ContratoQueueEntry."Starting Time" := 0T;
        ContratoQueueEntry."Ending Time" := 0T;
        clear(ContratoQueueEntry."Expiration Date/Time");
        clear(ContratoQueueEntry."System Task ID");
        ContratoQueueEntry.Insert(true);
        OnRunContratoQueueEntryOnceOnAfterContratoQueueEntryInsert(SelectedContratoQueueEntry, ContratoQueueEntry);
        Commit();

        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033);

        //TelemetrySubscribers.SetJobQueueTelemetryDimensions(ContratoQueueEntry, Dimensions);

        Session.LogMessage('0000FMG', RunContratoQueueOnceTxt, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, Dimensions);
        GlobalLanguage(CurrentLanguage);

        // Run the Contrato queue
        SuccessDispatcher := Codeunit.run(Codeunit::"Job Queue Dispatcher", ContratoQueueEntry);

        // If JQ fails, run the error handler
        if not SuccessDispatcher then begin
            SuccessErrorHandler := Codeunit.run(Codeunit::"Job Queue Error Handler", ContratoQueueEntry);

            // If the error handler fails, save the error (Non-AL errors will automatically surface to end-user)
            // If it is unable to save the error (No permission etc), it should also just be surfaced to the end-user.
            if not SuccessErrorHandler then begin
                ContratoQueueEntry.SetError(GetLastErrorText());
                ContratoQueueEntry.InsertLogEntry(ContratoQueueLogEntry);
                ContratoQueueEntry.FinalizeLogEntry(ContratoQueueLogEntry, GetLastErrorCallStack());
                Commit();
            end;
        end;

        Window.Close();
        if ContratoQueueEntry.Find() then
            if ContratoQueueEntry.Delete() then;
        ContratoQueueLogEntry.SetRange(ID, ContratoQueueEntry.ID);
        if ContratoQueueLogEntry.FindFirst() then
            if ContratoQueueLogEntry.Status = ContratoQueueLogEntry.Status::Success then
                Message(ExecuteEndSuccessMsg, ContratoQueueLogEntry.Status)
            else
                Message(ExecuteEndErrorMsg, ContratoQueueLogEntry.Status, ContratoQueueLogEntry."Error Message");
    end;

    internal procedure SendForApproval(var ContratoQueueEntry: Record "Contrato Queue Entry")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        /*  if ApprovalsMgmt.CheckContratoQueueEntryApprovalEnabled() then begin
             ContratoQueueEntry.SetStatus(ContratoQueueEntry.Status::"On Hold");
             Commit();
             ApprovalsMgmt.OnSendContratoQueueEntryForApproval(ContratoQueueEntry);
             FeatureTelemetry.LogUsage('0000JQE', ContratoQueueDelegatedAdminCategoryTxt, DelegatedAdminSendingApprovalLbl);
         end else begin
             FeatureTelemetry.LogError('0000JQD', ContratoQueueDelegatedAdminCategoryTxt, DelegatedAdminSendingApprovalLbl, ContratoQueueWorkflowSetupErr);
             Error(ContratoQueueWorkflowSetupErr);
         end; */
    end;

    procedure CheckAndRefreshCategoryRecoveryTasks()
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
        ContratoQueueCategory: Record "Contrato Queue Category";
        Categories: List of [Code[10]];
        Category: Code[10];
    begin
        if not ContratoQueueEntry.WritePermission() then
            exit;
        if not ContratoQueueCategory.WritePermission() then
            exit;

        ContratoQueueEntry.ReadIsolation(IsolationLevel::ReadUnCommitted);
        ContratoQueueEntry.SetFilter("Contrato Queue Category Code", '<>''''');
        ContratoQueueEntry.SetRange(Status, ContratoQueueEntry.Status::Waiting);
        ContratoQueueEntry.SetLoadFields("Contrato Queue Category Code");
        if not ContratoQueueEntry.FindSet() then
            exit;

        repeat
            if not Categories.Contains(ContratoQueueEntry."Contrato Queue Category Code") then
                Categories.Add(ContratoQueueEntry."Contrato Queue Category Code");
        until ContratoQueueEntry.Next() = 0;

        ContratoQueueCategory.ReadIsolation(IsolationLevel::ReadUncommitted);
        foreach Category in Categories do
            if ContratoQueueCategory.Get(Category) then
                if not IsNullGuid(ContratoQueueCategory."Recovery Task Id") then
                    if not TaskScheduler.TaskExists(ContratoQueueCategory."Recovery Task Id") then
                        ContratoQueueEntry.RefreshRecoveryTask(ContratoQueueCategory);
    end;

    /// <summary>
    /// To find stale Contratos (in process Contratos with no scheduled tasks) and set them to error state.
    /// For both JQE and JQLE
    /// </summary>
    procedure FindStaleContratosAndSetError()
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
        ContratoQueueLogEntry: Record "Contrato Queue Log Entry";
        ContratoQueueEntry2: Record "Contrato Queue Entry";
        ContratoQueueLogEntry2: Record "Contrato Queue Log Entry";
        DidSessionStart: Boolean;
        DidSessionStop: Boolean;
    begin
        // Find all in process Contrato queue entries
        ContratoQueueEntry.ReadIsolation(IsolationLevel::ReadUnCommitted);
        ContratoQueueEntry.SetLoadFields(ID, "System Task ID", "User Service Instance ID", "User Session ID", Status, "User Session Started");
        ContratoQueueEntry.SetFilter(Status, '%1|%2', ContratoQueueEntry.Status::Ready, ContratoQueueEntry.Status::"In Process");
        ContratoQueueEntry.SetRange(Scheduled, false);
        ContratoQueueEntry.SetFilter(SystemModifiedAt, '<%1', CurrentDateTime() - GetCheckDelayInMilliseconds());  // Not modified in the last 10 minutes
        ContratoQueueEntry2.ReadIsolation(IsolationLevel::UpdLock);
        if ContratoQueueEntry.FindSet() then
            repeat
                // Check if Contrato is still running or stale
                // JQE is stale if it has task no longer exists
                // If stale, set to error
                if not TaskScheduler.TaskExists(ContratoQueueEntry."System Task ID") then begin
                    DidSessionStart := SessionStarted(ContratoQueueEntry."User Service Instance ID", ContratoQueueEntry."User Session ID", ContratoQueueEntry."User Session Started");
                    if DidSessionStart then
                        DidSessionStop := SessionStopped(ContratoQueueEntry."User Service Instance ID", ContratoQueueEntry."User Session ID", ContratoQueueEntry."User Session Started");
                    if not DidSessionStart or DidSessionStart and DidSessionStop then begin
                        ContratoQueueEntry2.Get(ContratoQueueEntry.ID);
                        ContratoQueueEntry2.SetError(ContratoSomethingWentWrongMsg);
                        OnFindStaleContratosAndSetErrorOnAfterSetError(ContratoQueueEntry2);

                        StaleContratoQueueEntryTelemetry(ContratoQueueEntry2);
                    end;
                end;
            until ContratoQueueEntry.Next() = 0;

        // Find all in process Contrato queue log entries
        ContratoQueueLogEntry.ReadIsolation(IsolationLevel::ReadUnCommitted);
        ContratoQueueLogEntry.SetLoadFields("Entry No.", ID);
        ContratoQueueLogEntry.SetRange(Status, ContratoQueueLogEntry.Status::"In Process");
        ContratoQueueLogEntry.SetFilter(SystemModifiedAt, '<%1', CurrentDateTime() - GetCheckDelayInMilliseconds());  // Not modified in the last 10 minutes
        ContratoQueueLogEntry2.ReadIsolation(IsolationLevel::UpdLock);
        ContratoQueueEntry.SetAutoCalcFields(Scheduled);
        ContratoQueueEntry.SetLoadFields(ID, Status, Scheduled);
        if ContratoQueueLogEntry.FindSet() then
            repeat
                if not ContratoQueueEntry.Get(ContratoQueueLogEntry.ID) or (ContratoQueueEntry.Status = ContratoQueueEntry.Status::Error) or not ContratoQueueEntry.Scheduled then begin
                    ContratoQueueLogEntry2.Get(ContratoQueueLogEntry."Entry No.");
                    ContratoQueueLogEntry2.Status := ContratoQueueLogEntry2.Status::Error;
                    ContratoQueueLogEntry2."Error Message" := ContratoSomethingWentWrongMsg;
                    if ContratoQueueLogEntry2."End Date/Time" = 0DT then
                        ContratoQueueLogEntry2."End Date/Time" := ContratoQueueLogEntry2."Start Date/Time";
                    ContratoQueueLogEntry2.Modify();

                    StaleContratoQueueLogEntryTelemetry(ContratoQueueLogEntry2);
                end;
            until ContratoQueueLogEntry.Next() = 0;
    end;

    local procedure GetCheckDelayInMilliseconds(): Integer
    var
        DelayInMinutes: Integer;
    begin
        DelayInMinutes := 10;
        OnGetCheckDelayInMinutes(DelayInMinutes);
        if DelayInMinutes < 0 then
            DelayInMinutes := 0;
        exit(1000 * 60 * DelayInMinutes); // 10 minutes
    end;

    local procedure SessionStarted(ServerInstanceID: Integer; SessionID: Integer; AfterDateTime: DateTime): Boolean
    var
        SessionEvent: Record "Session Event";
    begin
        exit(SessionExists(ServerInstanceID, SessionID, AfterDateTime, SessionEvent."Event Type"::Logon));
    end;

    local procedure SessionStopped(ServerInstanceID: Integer; SessionID: Integer; AfterDateTime: DateTime): Boolean
    var
        SessionEvent: Record "Session Event";
    begin
        exit(SessionExists(ServerInstanceID, SessionID, AfterDateTime, SessionEvent."Event Type"::Logoff));
    end;

    local procedure SessionExists(ServerInstanceID: Integer; SessionID: Integer; AfterDateTime: DateTime; EventType: Option): Boolean
    var
        SessionEvent: Record "Session Event";
    begin
        if AfterDateTime = 0DT then
            AfterDateTime := CurrentDateTime - 24 * 60 * 60 * 1000;     // 24hrs ago
        SessionEvent.SetRange("Server Instance ID", ServerInstanceID);
        SessionEvent.SetRange("Session ID", SessionID);
        SessionEvent.SetFilter("Event Datetime", '>%1', AfterDateTime - 600000);  // because session id's start from 1 after server restart
        SessionEvent.SetRange("Event Type", EventType);
        exit(not SessionEvent.IsEmpty());
    end;

    local procedure StaleContratoQueueEntryTelemetry(ContratoQueueEntry: Record "Contrato Queue Entry")
    var
        CurrentLanguage: Integer;
        Dimensions: Dictionary of [Text, Text];
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033);

        //TelemetrySubscribers.SetContratoQueueTelemetryDimensions(ContratoQueueEntry, Dimensions);

        Session.LogMessage('0000FMH', TelemetryStaleContratoQueueEntryTxt, Verbosity::Warning, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, Dimensions);

        GlobalLanguage(CurrentLanguage);
    end;

    local procedure StaleContratoQueueLogEntryTelemetry(ContratoQueueLogEntry: Record "Contrato Queue Log Entry")
    var
        CurrentLanguage: Integer;
        Dimensions: Dictionary of [Text, Text];
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033);

        // TelemetrySubscribers.SetContratoQueueTelemetryDimensions(ContratoQueueLogEntry, Dimensions);

        Session.LogMessage('0000FMI', TelemetryStaleContratoQueueLogEntryTxt, Verbosity::Warning, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, Dimensions);

        GlobalLanguage(CurrentLanguage);
    end;

    internal procedure TooManyScheduledTasksNotification()
    var
        ScheduledTaskNotification: Notification;
        NoOfScheduledTasks: Integer;
    begin
        NoOfScheduledTasks := GetNumberOfScheduledTasks();
        if NoOfScheduledTasks >= 100000 then begin
            ScheduledTaskNotification.Id := TooManyScheduledTasksNotificationGuidLbl;
            ScheduledTaskNotification.Message := TooManyScheduledTasksNotificationMsg;
            ScheduledTaskNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
            ScheduledTaskNotification.AddAction(
              TooManyScheduledTasksLinkTxt, CODEUNIT::"Contrato Queue Management", 'TooManyScheduledTasksDocs');
            ScheduledTaskNotification.Send();
        end;
    end;

    internal procedure GetScheduledTasks(): Integer
    begin
        exit(GetNumberOfScheduledTasks())
    end;

    internal procedure GetScheduledTasksForUser(UserId: Guid): Integer
    begin
        exit(GetNumberOfScheduledTasksForUser(UserId))
    end;

    internal procedure TooManyScheduledTasksDocs(ScheduledTaskNotification: Notification)
    begin
        Hyperlink('https://aka.ms/ContratoQueueDocs');
    end;

    local procedure GetNumberOfScheduledTasksForUser(UserId: Guid): Integer
    var
        ScheduledTasks: Record "Scheduled Task";
    begin
        if ScheduledTasks.ReadPermission() then begin
            ScheduledTasks.SetRange("Is Ready", true);
            ScheduledTasks.SetRange("User ID", UserId);
            exit(ScheduledTasks.Count());
        end;

        exit(0);
    end;

    local procedure GetNumberOfScheduledTasks(): Integer
    var
        ScheduledTasks: Record "Scheduled Task";
    begin
        if ScheduledTasks.ReadPermission() then begin
            ScheduledTasks.SetRange("Is Ready", true);
            exit(ScheduledTasks.Count());
        end;

        exit(0);
    end;

    local procedure DeleteErrorMessageRegister(RegisterId: Guid)
    var
        ErrorMessageRegister: Record "Error Message Register";
    begin
        if IsNullGuid(RegisterId) then
            exit;

        ErrorMessageRegister.SetRange(ID, RegisterId);
        ErrorMessageRegister.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'ScheduleReport', '', false, false)]
    local procedure ScheduleReport(ReportId: Integer; RequestPageXml: Text; var Scheduled: Boolean)
    var
        ScheduleAReport: Page "Schedule a Report";
    begin
        Scheduled := ScheduleAReport.ScheduleAReport(ReportId, RequestPageXml);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contrato Queue Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnStatusChanged(Rec: Record "Contrato Queue Entry"; xRec: Record "Contrato Queue Entry"; RunTrigger: Boolean)
    var
        CurrentLanguage: Integer;
        Dimensions: Dictionary of [Text, Text];
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Status = xRec.Status then
            exit;

        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033);

        //TelemetrySubscribers.SetContratoQueueTelemetryDimensions(Rec, Dimensions);
        Dimensions.Add('ContratoQueueOldStatus', Format(xRec.Status));

        Session.LogMessage('0000FNM', ContratoQueueStatusChangeTxt, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, Dimensions);

        GlobalLanguage(CurrentLanguage);

        if Rec."Error Message Register Id" <> xRec."Error Message Register Id" then
            DeleteErrorMessageRegister(xRec."Error Message Register Id");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contrato Queue Entry", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteContratoQueueEntry(var Rec: Record "Contrato Queue Entry"; RunTrigger: Boolean)
    var
        ContratoQueueLogEntry: Record "Contrato Queue Log Entry";
    begin
        if IsNullGuid(Rec."Error Message Register Id") then
            exit;

        ContratoQueueLogEntry.SetRange("Error Message Register Id", Rec."Error Message Register Id");
        if ContratoQueueLogEntry.IsEmpty() then
            DeleteErrorMessageRegister(Rec."Error Message Register Id");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contrato Queue Log Entry", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteContratoQueueLogEntry(var Rec: Record "Contrato Queue Log Entry"; RunTrigger: Boolean)
    var
        ContratoQueueEntry: Record "Contrato Queue Entry";
    begin
        if IsNullGuid(Rec."Error Message Register Id") then
            exit;

        ContratoQueueEntry.SetRange("Error Message Register Id", Rec."Error Message Register Id");
        if ContratoQueueEntry.IsEmpty() then
            DeleteErrorMessageRegister(Rec."Error Message Register Id");
    end;

    /// <Summary>Used for test. Sets the minimum age of stale Contrato queue entries and Contrato queue log entries.</Summary>
    /// <Parameters>DelayInMinutes defaults to 10 minutes but can be overridden to a longer or shorter time, including 0</Parameters>
    [IntegrationEvent(false, false)]
    local procedure OnGetCheckDelayInMinutes(var DelayInMinutes: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunContratoQueueEntryOnceOnAfterContratoQueueEntryInsert(SelectedContratoQueueEntry: Record "Contrato Queue Entry"; ContratoQueueEntry: Record "Contrato Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindStaleContratosAndSetErrorOnAfterSetError(var ContratoQueueEntry: Record "Contrato Queue Entry")
    begin
    end;
}

