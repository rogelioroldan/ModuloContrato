codeunit 50221 "Contrato Archive Management"
{
    Permissions = tabledata "Contrato Archive" = ri,
                  tabledata "Contrato Task Archive" = rim,
                  tabledata "Contrato Planning Line Archive" = rim,
                  tabledata "Comment Line" = r,
                  tabledata "Comment Line Archive" = ri;

    trigger OnRun()
    begin
    end;

    var
        RecordLinkManagement: Codeunit "Record Link Management";

        RestoreQst: Label 'Do you want to Restore %1 %2 Version %3?', Comment = '%1 = Contrato Caption, %2 = Contrato No., %3 = Version No.';
        RestoreMsg: Label '%1 %2 has been restored.', Comment = '%1 = Contrato Caption, %2 = Contrato No.';
        ArchiveQst: Label 'Archive %1 no.: %2?', Comment = '%1 = Contrato Caption, %2 = Contrato No.';
        JobArchiveMsg: Label 'Project %1 has been archived.', Comment = '%1 = Project No.';
        MissingJobErr: Label 'Project %1 does not exist anymore.\It is not possible to restore the Project.', Comment = '%1 = Project No.';
        CompletedJobStatusErr: Label 'Status must not be Completed in order to restore the Project: No. = %1', Comment = '%1 = Project No.';
        JobLedgerEntryExistErr: Label 'Project Ledger Entries exist for Project No. %1.\It is not possible to restore the Project.', Comment = '%1 = Project No.';
        SalesInvoiceExistErr: Label 'Outstanding Sales Invoice exists for Project No. %1.\It is not possible to restore the Project.', Comment = '%1 = Project No.';

    procedure AutoArchiveJob(var Contrato: Record Contrato)
    var
        JobSetup: Record "Jobs Setup";
    begin
        JobSetup.Get();
        case JobSetup."Archive Jobs" of
            JobSetup."Archive Jobs"::Always:
                StoreJob(Contrato, false);
            JobSetup."Archive Jobs"::Question:
                ArchiveJob(Contrato);
        end;
    end;

    procedure ArchiveJob(var Contrato: Record "Contrato")
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if ConfirmManagement.GetResponseOrDefault(
             StrSubstNo(ArchiveQst, Contrato.TableCaption(), Contrato."No."), true)
        then begin
            StoreJob(Contrato, false);
            Message(JobArchiveMsg, Contrato."No.");
        end;
    end;

    procedure StoreJob(var Contrato: Record Contrato; InteractionExist: Boolean)
    var
        JobArchive: Record "Contrato Archive";
        JobTask: Record "Contrato Task";
        JobTaskArchive: Record "Contrato Task Archive";
        JobPlanningLine: Record "Contrato Planning Line";
        JobPlanningLineArchive: Record "Contrato Planning Line Archive";
        CommentLineTableName: Enum "Comment Line Table Name";
    begin
        JobArchive.Init();
        JobArchive.TransferFields(Contrato);
        JobArchive."Archived By" := CopyStr(UserId(), 1, MaxStrLen(JobArchive."Archived By"));
        JobArchive."Date Archived" := Today();
        JobArchive."Time Archived" := Time();
        JobArchive."Version No." := GetNextVersionNo(Database::Contrato, Contrato."No.");
        JobArchive."Interaction Exist" := InteractionExist;
        RecordLinkManagement.CopyLinks(Contrato, JobArchive);
        OnStoreJobOnBeforeInsertJobArchive(Contrato, JobArchive);
        JobArchive.Insert();

        StoreComments(CommentLineTableName::Contrato, JobArchive."No.", JobArchive."Version No.");

        OnStoreJobOnBeforeStoreJobTaskAndJobPlanningLine(JobTask, JobPlanningLine, Contrato);

        JobTask.SetRange("Contrato No.", Contrato."No.");
        if JobTask.FindSet() then
            repeat
                JobTaskArchive.Init();
                JobTaskArchive.TransferFields(JobTask);
                JobTaskArchive."Version No." := JobArchive."Version No.";
                RecordLinkManagement.CopyLinks(JobTask, JobTaskArchive);
                OnStoreJobOnBeforeInsertJobTaskArchive(JobTask, JobTaskArchive);
                JobTaskArchive.Insert();
                AddCalculatedValuesToJobTaskArchive(JobTaskArchive, JobTask);
            until JobTask.Next() = 0;

        JobPlanningLine.SetRange("Contrato No.", Contrato."No.");
        if JobPlanningLine.FindSet() then
            repeat
                JobPlanningLineArchive.Init();
                JobPlanningLineArchive.TransferFields(JobPlanningLine);
                JobPlanningLineArchive."Version No." := JobArchive."Version No.";
                RecordLinkManagement.CopyLinks(JobPlanningLine, JobPlanningLineArchive);
                OnStoreJobOnBeforeInsertJobPlanningLineArchive(JobPlanningLine, JobPlanningLineArchive);
                JobPlanningLineArchive.Insert();
                AddCalculatedValuesToJobPlanningLineArchive(JobPlanningLineArchive, JobPlanningLine);
            until JobPlanningLine.Next() = 0;

        OnAfterStoreJob(Contrato, JobArchive);
    end;

    local procedure AddCalculatedValuesToJobPlanningLineArchive(var JobPlanningLineArchive: Record "Contrato Planning Line Archive"; var JobPlanningLine: Record "Contrato Planning Line")
    begin
        JobPlanningLine.CalcFields("Invoiced Amount (LCY)", "Invoiced Cost Amount (LCY)", "Qty. Transferred to Invoice", "Qty. Invoiced",
                "Reserved Quantity", "Reserved Qty. (Base)", "Pick Qty.", "Pick Qty. (Base)", "Qty. on Journal");
        JobPlanningLineArchive."Invoiced Amount (LCY)" := JobPlanningLine."Invoiced Amount (LCY)";
        JobPlanningLineArchive."Invoiced Cost Amount (LCY)" := JobPlanningLine."Invoiced Cost Amount (LCY)";
        JobPlanningLineArchive."Qty. Transferred to Invoice" := JobPlanningLine."Qty. Transferred to Invoice";
        JobPlanningLineArchive."Qty. Invoiced" := JobPlanningLine."Qty. Invoiced";
        JobPlanningLineArchive."Reserved Quantity" := JobPlanningLine."Reserved Quantity";
        JobPlanningLineArchive."Reserved Qty. (Base)" := JobPlanningLine."Reserved Qty. (Base)";
        JobPlanningLineArchive."Pick Qty." := JobPlanningLine."Pick Qty.";
        JobPlanningLineArchive."Qty. on Journal" := JobPlanningLine."Qty. on Journal";
        OnAddCalculatedValuesToJobPlanningLineArchiveOnBeforeModifyJobPlanningLineArchive(JobPlanningLine, JobPlanningLineArchive);
        JobPlanningLineArchive.Modify(true);
    end;

    local procedure AddCalculatedValuesToJobTaskArchive(var JobTaskArchive: Record "Contrato Task Archive"; var JobTask: Record "Contrato Task")
    begin
        JobTask.CalcFields("Usage (Total Cost)", "Usage (Total Price)", "Contract (Invoiced Price)", "Contract (Invoiced Cost)",
            "Outstanding Orders", "Amt. Rcd. Not Invoiced");
        JobTaskArchive."Usage (Total Cost)" := JobTask."Usage (Total Cost)";
        JobTaskArchive."Usage (Total Price)" := JobTask."Usage (Total Price)";
        JobTaskArchive."Contract (Invoiced Price)" := JobTask."Contract (Invoiced Price)";
        JobTaskArchive."Contract (Invoiced Cost)" := JobTask."Contract (Invoiced Cost)";
        JobTaskArchive."Outstanding Orders" := JobTask."Outstanding Orders";
        JobTaskArchive."Amt. Rcd. Not Invoiced" := JobTask."Amt. Rcd. Not Invoiced";
        OnAddCalculatedValuesToJobTaskArchiveOnBeforeModifyJobTaskArchive(JobTask, JobTaskArchive);
        JobTaskArchive.Modify(true);
    end;

    local procedure StoreComments(TableName: Enum "Comment Line Table Name"; DocNo: Code[20]; VersionNo: Integer)
    var
        CommentLine: Record "Comment Line";
        CommentLineArchive: Record "Comment Line Archive";
    begin
        CommentLine.SetRange("Table Name", TableName);
        CommentLine.SetRange("No.", DocNo);
        if CommentLine.FindSet() then
            repeat
                CommentLineArchive.Init();
                CommentLineArchive.TransferFields(CommentLine);
                CommentLineArchive."Version No." := VersionNo;
                CommentLineArchive.Insert();
            until CommentLine.Next() = 0;
    end;

    local procedure RestoreComments(TableName: Enum "Comment Line Table Name"; DocNo: Code[20]; VersionNo: Integer)
    var
        CommentLine: Record "Comment Line";
        CommentLineArchive: Record "Comment Line Archive";
    begin
        CommentLineArchive.SetRange("Table Name", TableName);
        CommentLineArchive.SetRange("No.", DocNo);
        CommentLineArchive.SetRange("Version No.", VersionNo);
        if CommentLineArchive.FindSet() then
            repeat
                CommentLine.Init();
                CommentLine.TransferFields(CommentLineArchive);
                CommentLine.Insert();
            until CommentLineArchive.Next() = 0;
    end;

    procedure RestoreJob(var JobArchive: Record "Contrato Archive")
    var
        Contrato: Record Contrato;
        CommentLine: Record "Comment Line";
        ConfirmManagement: Codeunit "Confirm Management";
        RestoreArchivedJob: Boolean;
    begin
        CheckJobRestorePermissions(Contrato, JobArchive);

        RestoreArchivedJob := false;
        if ConfirmManagement.GetResponseOrDefault(
            StrSubstNo(RestoreQst, Contrato.TableCaption(), JobArchive."No.", JobArchive."Version No."), true)
        then
            RestoreArchivedJob := true;

        if RestoreArchivedJob then begin
            CommentLine.SetRange("Table Name", CommentLine."Table Name"::Contrato);
            CommentLine.SetRange("No.", Contrato."No.");
            CommentLine.DeleteAll();

            Contrato.Delete();
            OnRestoreJobOnAfterDeleteJob(Contrato);

            Contrato.Init();
            Contrato."No." := JobArchive."No.";
            Contrato.TransferFields(JobArchive);
            OnRestoreJobOnBeforeInsertJob(JobArchive, Contrato);
            Contrato.Insert(true);
            RecordLinkManagement.CopyLinks(JobArchive, Contrato);
            Contrato.Modify(true);

            RestoreComments(CommentLine."Table Name"::Contrato, JobArchive."No.", JobArchive."Version No.");
            RestoreJobTasks(JobArchive, Contrato);
            OnAfterRestoreJob(JobArchive, Contrato);
            Message(RestoreMsg, Contrato.TableCaption(), JobArchive."No.");
        end;
    end;

    local procedure RestoreJobTasks(var JobArchive: Record "Contrato Archive"; Contrato: Record Contrato)
    var
        JobTask: Record "Contrato Task";
        JobTaskDim: Record "Contrato Task Dimension";
        JobTaskArchive: Record "Contrato Task Archive";
        JobPlanningLine: Record "Contrato Planning Line";
    begin
        JobTask.SetRange("Contrato No.", Contrato."No.");
        JobTask.DeleteAll();

        JobTaskDim.SetRange("Contrato No.", Contrato."No.");
        if not JobTaskDim.IsEmpty() then
            JobTaskDim.DeleteAll();

        JobPlanningLine.SetRange("Contrato No.", Contrato."No.");
        JobPlanningLine.DeleteAll();

        JobTaskArchive.SetRange("Contrato No.", JobArchive."No.");
        JobTaskArchive.SetRange("Version No.", JobArchive."Version No.");
        if JobTaskArchive.FindSet() then
            repeat
                RestoreSingleJobTask(JobTaskArchive, Contrato);
                RestoreJobPlanningLines(JobTaskArchive);
            until JobTaskArchive.Next() = 0;
    end;

    local procedure RestoreSingleJobTask(JobTaskArchive: Record "Contrato Task Archive"; Contrato: Record Contrato)
    var
        JobTask: Record "Contrato Task";
        JobTaskDimension: Record "Contrato Task Dimension";
    begin
        JobTaskDimension.SetRange("Contrato No.", Contrato."No.");
        JobTaskDimension.SetRange("Contrato Task No.", JobTaskArchive."Contrato Task No.");
        JobTaskDimension.DeleteAll();

        JobTask.Init();
        JobTask.TransferFields(JobTaskArchive);
        OnRestoreSingleJobTaskOnBeforeInsertJobTask(JobTaskArchive, JobTask);
        JobTask.Insert(true);
        RecordLinkManagement.CopyLinks(JobTaskArchive, JobTask);
        JobTask.Modify(true);
        OnAfterRestoreSingleJobTask(JobTaskArchive, JobTask);
    end;

    local procedure RestoreJobPlanningLines(var JobTaskArchive: Record "Contrato Task Archive")
    var
        JobPlanningLine: Record "Contrato Planning Line";
        JobPlanningLineArchive: Record "Contrato Planning Line Archive";
    begin
        JobPlanningLineArchive.SetRange("Contrato No.", JobTaskArchive."Contrato No.");
        JobPlanningLineArchive.SetRange("Contrato Task No.", JobTaskArchive."Contrato Task No.");
        JobPlanningLineArchive.SetRange("Version No.", JobTaskArchive."Version No.");
        if JobPlanningLineArchive.FindSet() then
            repeat
                JobPlanningLine.Init();
                JobPlanningLine.TransferFields(JobPlanningLineArchive);
                OnRestoreJobPlanningLinesOnBeforeInsertJobPlanningLine(JobPlanningLineArchive, JobPlanningLine);
                JobPlanningLine.Insert(true);
                RecordLinkManagement.CopyLinks(JobPlanningLineArchive, JobPlanningLine);
                JobPlanningLine.Modify(true);
                OnAfterRestoreSingleJobPlanningLine(JobPlanningLineArchive, JobPlanningLine);
            until JobPlanningLineArchive.Next() = 0;
    end;

    local procedure CheckJobRestorePermissions(var Contrato: Record Contrato; var JobArchive: Record "Contrato Archive")
    var
        JobLedgerEntry: Record "Contrato Ledger Entry";
        SalesLine: Record "Sales Line";
    begin
        if not Contrato.Get(JobArchive."No.") then
            Error(MissingJobErr, JobArchive."No.");

        if Contrato.Status = Contrato.Status::Completed then
            Error(CompletedJobStatusErr, Contrato."No.");

        JobLedgerEntry.SetRange("Contrato No.", Contrato."No.");
        if not JobLedgerEntry.IsEmpty() then
            Error(JobLedgerEntryExistErr, Contrato."No.");

        SalesLine.SetRange("Job No.", Contrato."No.");
        if not SalesLine.IsEmpty() then
            Error(SalesInvoiceExistErr, Contrato."No.");

        OnAfterCheckJobRestorePermissions(JobArchive, Contrato);
    end;

    procedure GetNextVersionNo(TableId: Integer; DocNo: Code[20]) VersionNo: Integer
    var
        JobArchive: Record "Contrato Archive";
    begin
        case TableId of
            DATABASE::Contrato:
                begin
                    JobArchive.LockTable();
                    JobArchive.SetRange("No.", DocNo);
                    if JobArchive.FindLast() then
                        exit(JobArchive."Version No." + 1);

                    exit(1);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreJobOnBeforeInsertJobArchive(Contrato: Record Contrato; var JobArchive: Record "Contrato Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreJobOnBeforeInsertJobTaskArchive(JobTask: Record "Contrato Task"; var JobTaskArchive: Record "Contrato Task Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreJobOnBeforeInsertJobPlanningLineArchive(JobPlanningLine: Record "Contrato Planning Line"; var JobPlanningLineArchive: Record "Contrato Planning Line Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterStoreJob(Contrato: Record Contrato; var JobArchive: Record "Contrato Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreJob(JobArchive: Record "Contrato Archive"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreJobOnAfterDeleteJob(Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreSingleJobTask(JobTaskArchive: Record "Contrato Task Archive"; var JobTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreSingleJobPlanningLine(JobPlanningLineArchive: Record "Contrato Planning Line Archive"; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddCalculatedValuesToJobTaskArchiveOnBeforeModifyJobTaskArchive(var JobTask: Record "Contrato Task"; var JobTaskArchive: Record "Contrato Task Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddCalculatedValuesToJobPlanningLineArchiveOnBeforeModifyJobPlanningLineArchive(var JobPlanningLine: Record "Contrato Planning Line"; var JobPlanningLineArchive: Record "Contrato Planning Line Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckJobRestorePermissions(JobArchive: Record "Contrato Archive"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreSingleJobTaskOnBeforeInsertJobTask(var JobTaskArchive: Record "Contrato Task Archive"; var JobTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreJobPlanningLinesOnBeforeInsertJobPlanningLine(var JobPlanningLineArchive: Record "Contrato Planning Line Archive"; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreJobOnBeforeInsertJob(JobArchive: Record "Contrato Archive"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreJobOnBeforeStoreJobTaskAndJobPlanningLine(var JobTask: Record "Contrato Task"; var JobPlanningLine: Record "Contrato Planning Line"; var Contrato: Record Contrato)
    begin
    end;
}

