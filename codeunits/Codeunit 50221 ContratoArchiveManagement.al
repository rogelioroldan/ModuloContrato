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
        ContratoArchiveMsg: Label 'Project %1 has been archived.', Comment = '%1 = Project No.';
        MissingContratoErr: Label 'Project %1 does not exist anymore.\It is not possible to restore the Project.', Comment = '%1 = Project No.';
        CompletedContratoStatusErr: Label 'Status must not be Completed in order to restore the Project: No. = %1', Comment = '%1 = Project No.';
        ContratoLedgerEntryExistErr: Label 'Project Ledger Entries exist for Project No. %1.\It is not possible to restore the Project.', Comment = '%1 = Project No.';
        SalesInvoiceExistErr: Label 'Outstanding Sales Invoice exists for Project No. %1.\It is not possible to restore the Project.', Comment = '%1 = Project No.';

    procedure AutoArchiveContrato(var Contrato: Record Contrato)
    var
        ContratoSetup: Record "Contratos Setup";
    begin
        ContratoSetup.Get();
        case ContratoSetup."Archive Contratos" of
            ContratoSetup."Archive Contratos"::Always:
                StoreContrato(Contrato, false);
            ContratoSetup."Archive Contratos"::Question:
                ArchiveContrato(Contrato);
        end;
    end;

    procedure ArchiveContrato(var Contrato: Record "Contrato")
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if ConfirmManagement.GetResponseOrDefault(
             StrSubstNo(ArchiveQst, Contrato.TableCaption(), Contrato."No."), true)
        then begin
            StoreContrato(Contrato, false);
            Message(ContratoArchiveMsg, Contrato."No.");
        end;
    end;

    procedure StoreContrato(var Contrato: Record Contrato; InteractionExist: Boolean)
    var
        ContratoArchive: Record "Contrato Archive";
        ContratoTask: Record "Contrato Task";
        ContratoTaskArchive: Record "Contrato Task Archive";
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoPlanningLineArchive: Record "Contrato Planning Line Archive";
        CommentLineTableName: Enum "Comment Line Table Name";
    begin
        ContratoArchive.Init();
        ContratoArchive.TransferFields(Contrato);
        ContratoArchive."Archived By" := CopyStr(UserId(), 1, MaxStrLen(ContratoArchive."Archived By"));
        ContratoArchive."Date Archived" := Today();
        ContratoArchive."Time Archived" := Time();
        ContratoArchive."Version No." := GetNextVersionNo(Database::Contrato, Contrato."No.");
        ContratoArchive."Interaction Exist" := InteractionExist;
        RecordLinkManagement.CopyLinks(Contrato, ContratoArchive);
        OnStoreContratoOnBeforeInsertContratoArchive(Contrato, ContratoArchive);
        ContratoArchive.Insert();

        StoreComments(CommentLineTableName::Contrato, ContratoArchive."No.", ContratoArchive."Version No.");

        OnStoreContratoOnBeforeStoreContratoTaskAndContratoPlanningLine(ContratoTask, ContratoPlanningLine, Contrato);

        ContratoTask.SetRange("Contrato No.", Contrato."No.");
        if ContratoTask.FindSet() then
            repeat
                ContratoTaskArchive.Init();
                ContratoTaskArchive.TransferFields(ContratoTask);
                ContratoTaskArchive."Version No." := ContratoArchive."Version No.";
                RecordLinkManagement.CopyLinks(ContratoTask, ContratoTaskArchive);
                OnStoreContratoOnBeforeInsertContratoTaskArchive(ContratoTask, ContratoTaskArchive);
                ContratoTaskArchive.Insert();
                AddCalculatedValuesToContratoTaskArchive(ContratoTaskArchive, ContratoTask);
            until ContratoTask.Next() = 0;

        ContratoPlanningLine.SetRange("Contrato No.", Contrato."No.");
        if ContratoPlanningLine.FindSet() then
            repeat
                ContratoPlanningLineArchive.Init();
                ContratoPlanningLineArchive.TransferFields(ContratoPlanningLine);
                ContratoPlanningLineArchive."Version No." := ContratoArchive."Version No.";
                RecordLinkManagement.CopyLinks(ContratoPlanningLine, ContratoPlanningLineArchive);
                OnStoreContratoOnBeforeInsertContratoPlanningLineArchive(ContratoPlanningLine, ContratoPlanningLineArchive);
                ContratoPlanningLineArchive.Insert();
                AddCalculatedValuesToContratoPlanningLineArchive(ContratoPlanningLineArchive, ContratoPlanningLine);
            until ContratoPlanningLine.Next() = 0;

        OnAfterStoreContrato(Contrato, ContratoArchive);
    end;

    local procedure AddCalculatedValuesToContratoPlanningLineArchive(var ContratoPlanningLineArchive: Record "Contrato Planning Line Archive"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ContratoPlanningLine.CalcFields("Invoiced Amount (LCY)", "Invoiced Cost Amount (LCY)", "Qty. Transferred to Invoice", "Qty. Invoiced",
                "Reserved Quantity", "Reserved Qty. (Base)", "Pick Qty.", "Pick Qty. (Base)", "Qty. on Journal");
        ContratoPlanningLineArchive."Invoiced Amount (LCY)" := ContratoPlanningLine."Invoiced Amount (LCY)";
        ContratoPlanningLineArchive."Invoiced Cost Amount (LCY)" := ContratoPlanningLine."Invoiced Cost Amount (LCY)";
        ContratoPlanningLineArchive."Qty. Transferred to Invoice" := ContratoPlanningLine."Qty. Transferred to Invoice";
        ContratoPlanningLineArchive."Qty. Invoiced" := ContratoPlanningLine."Qty. Invoiced";
        ContratoPlanningLineArchive."Reserved Quantity" := ContratoPlanningLine."Reserved Quantity";
        ContratoPlanningLineArchive."Reserved Qty. (Base)" := ContratoPlanningLine."Reserved Qty. (Base)";
        ContratoPlanningLineArchive."Pick Qty." := ContratoPlanningLine."Pick Qty.";
        ContratoPlanningLineArchive."Qty. on Journal" := ContratoPlanningLine."Qty. on Journal";
        OnAddCalculatedValuesToContratoPlanningLineArchiveOnBeforeModifyContratoPlanningLineArchive(ContratoPlanningLine, ContratoPlanningLineArchive);
        ContratoPlanningLineArchive.Modify(true);
    end;

    local procedure AddCalculatedValuesToContratoTaskArchive(var ContratoTaskArchive: Record "Contrato Task Archive"; var ContratoTask: Record "Contrato Task")
    begin
        ContratoTask.CalcFields("Usage (Total Cost)", "Usage (Total Price)", "Contract (Invoiced Price)", "Contract (Invoiced Cost)",
            "Outstanding Orders", "Amt. Rcd. Not Invoiced");
        ContratoTaskArchive."Usage (Total Cost)" := ContratoTask."Usage (Total Cost)";
        ContratoTaskArchive."Usage (Total Price)" := ContratoTask."Usage (Total Price)";
        ContratoTaskArchive."Contract (Invoiced Price)" := ContratoTask."Contract (Invoiced Price)";
        ContratoTaskArchive."Contract (Invoiced Cost)" := ContratoTask."Contract (Invoiced Cost)";
        ContratoTaskArchive."Outstanding Orders" := ContratoTask."Outstanding Orders";
        ContratoTaskArchive."Amt. Rcd. Not Invoiced" := ContratoTask."Amt. Rcd. Not Invoiced";
        OnAddCalculatedValuesToContratoTaskArchiveOnBeforeModifyContratoTaskArchive(ContratoTask, ContratoTaskArchive);
        ContratoTaskArchive.Modify(true);
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

    procedure RestoreContrato(var ContratoArchive: Record "Contrato Archive")
    var
        Contrato: Record Contrato;
        CommentLine: Record "Comment Line";
        ConfirmManagement: Codeunit "Confirm Management";
        RestoreArchivedContrato: Boolean;
    begin
        CheckContratoRestorePermissions(Contrato, ContratoArchive);

        RestoreArchivedContrato := false;
        if ConfirmManagement.GetResponseOrDefault(
            StrSubstNo(RestoreQst, Contrato.TableCaption(), ContratoArchive."No.", ContratoArchive."Version No."), true)
        then
            RestoreArchivedContrato := true;

        if RestoreArchivedContrato then begin
            CommentLine.SetRange("Table Name", CommentLine."Table Name"::Contrato);
            CommentLine.SetRange("No.", Contrato."No.");
            CommentLine.DeleteAll();

            Contrato.Delete();
            OnRestoreContratoOnAfterDeleteContrato(Contrato);

            Contrato.Init();
            Contrato."No." := ContratoArchive."No.";
            Contrato.TransferFields(ContratoArchive);
            OnRestoreContratoOnBeforeInsertContrato(ContratoArchive, Contrato);
            Contrato.Insert(true);
            RecordLinkManagement.CopyLinks(ContratoArchive, Contrato);
            Contrato.Modify(true);

            RestoreComments(CommentLine."Table Name"::Contrato, ContratoArchive."No.", ContratoArchive."Version No.");
            RestoreContratoTasks(ContratoArchive, Contrato);
            OnAfterRestoreContrato(ContratoArchive, Contrato);
            Message(RestoreMsg, Contrato.TableCaption(), ContratoArchive."No.");
        end;
    end;

    local procedure RestoreContratoTasks(var ContratoArchive: Record "Contrato Archive"; Contrato: Record Contrato)
    var
        ContratoTask: Record "Contrato Task";
        ContratoTaskDim: Record "Contrato Task Dimension";
        ContratoTaskArchive: Record "Contrato Task Archive";
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoTask.SetRange("Contrato No.", Contrato."No.");
        ContratoTask.DeleteAll();

        ContratoTaskDim.SetRange("Contrato No.", Contrato."No.");
        if not ContratoTaskDim.IsEmpty() then
            ContratoTaskDim.DeleteAll();

        ContratoPlanningLine.SetRange("Contrato No.", Contrato."No.");
        ContratoPlanningLine.DeleteAll();

        ContratoTaskArchive.SetRange("Contrato No.", ContratoArchive."No.");
        ContratoTaskArchive.SetRange("Version No.", ContratoArchive."Version No.");
        if ContratoTaskArchive.FindSet() then
            repeat
                RestoreSingleContratoTask(ContratoTaskArchive, Contrato);
                RestoreContratoPlanningLines(ContratoTaskArchive);
            until ContratoTaskArchive.Next() = 0;
    end;

    local procedure RestoreSingleContratoTask(ContratoTaskArchive: Record "Contrato Task Archive"; Contrato: Record Contrato)
    var
        ContratoTask: Record "Contrato Task";
        ContratoTaskDimension: Record "Contrato Task Dimension";
    begin
        ContratoTaskDimension.SetRange("Contrato No.", Contrato."No.");
        ContratoTaskDimension.SetRange("Contrato Task No.", ContratoTaskArchive."Contrato Task No.");
        ContratoTaskDimension.DeleteAll();

        ContratoTask.Init();
        ContratoTask.TransferFields(ContratoTaskArchive);
        OnRestoreSingleContratoTaskOnBeforeInsertContratoTask(ContratoTaskArchive, ContratoTask);
        ContratoTask.Insert(true);
        RecordLinkManagement.CopyLinks(ContratoTaskArchive, ContratoTask);
        ContratoTask.Modify(true);
        OnAfterRestoreSingleContratoTask(ContratoTaskArchive, ContratoTask);
    end;

    local procedure RestoreContratoPlanningLines(var ContratoTaskArchive: Record "Contrato Task Archive")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoPlanningLineArchive: Record "Contrato Planning Line Archive";
    begin
        ContratoPlanningLineArchive.SetRange("Contrato No.", ContratoTaskArchive."Contrato No.");
        ContratoPlanningLineArchive.SetRange("Contrato Task No.", ContratoTaskArchive."Contrato Task No.");
        ContratoPlanningLineArchive.SetRange("Version No.", ContratoTaskArchive."Version No.");
        if ContratoPlanningLineArchive.FindSet() then
            repeat
                ContratoPlanningLine.Init();
                ContratoPlanningLine.TransferFields(ContratoPlanningLineArchive);
                OnRestoreContratoPlanningLinesOnBeforeInsertContratoPlanningLine(ContratoPlanningLineArchive, ContratoPlanningLine);
                ContratoPlanningLine.Insert(true);
                RecordLinkManagement.CopyLinks(ContratoPlanningLineArchive, ContratoPlanningLine);
                ContratoPlanningLine.Modify(true);
                OnAfterRestoreSingleContratoPlanningLine(ContratoPlanningLineArchive, ContratoPlanningLine);
            until ContratoPlanningLineArchive.Next() = 0;
    end;

    local procedure CheckContratoRestorePermissions(var Contrato: Record Contrato; var ContratoArchive: Record "Contrato Archive")
    var
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        SalesLine: Record "Sales Line";
    begin
        if not Contrato.Get(ContratoArchive."No.") then
            Error(MissingContratoErr, ContratoArchive."No.");

        if Contrato.Status = Contrato.Status::Completed then
            Error(CompletedContratoStatusErr, Contrato."No.");

        ContratoLedgerEntry.SetRange("Contrato No.", Contrato."No.");
        if not ContratoLedgerEntry.IsEmpty() then
            Error(ContratoLedgerEntryExistErr, Contrato."No.");

        SalesLine.SetRange("Job No.", Contrato."No.");
        if not SalesLine.IsEmpty() then
            Error(SalesInvoiceExistErr, Contrato."No.");

        OnAfterCheckContratoRestorePermissions(ContratoArchive, Contrato);
    end;

    procedure GetNextVersionNo(TableId: Integer; DocNo: Code[20]) VersionNo: Integer
    var
        ContratoArchive: Record "Contrato Archive";
    begin
        case TableId of
            DATABASE::Contrato:
                begin
                    ContratoArchive.LockTable();
                    ContratoArchive.SetRange("No.", DocNo);
                    if ContratoArchive.FindLast() then
                        exit(ContratoArchive."Version No." + 1);

                    exit(1);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreContratoOnBeforeInsertContratoArchive(Contrato: Record Contrato; var ContratoArchive: Record "Contrato Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreContratoOnBeforeInsertContratoTaskArchive(ContratoTask: Record "Contrato Task"; var ContratoTaskArchive: Record "Contrato Task Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreContratoOnBeforeInsertContratoPlanningLineArchive(ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoPlanningLineArchive: Record "Contrato Planning Line Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterStoreContrato(Contrato: Record Contrato; var ContratoArchive: Record "Contrato Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreContrato(ContratoArchive: Record "Contrato Archive"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreContratoOnAfterDeleteContrato(Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreSingleContratoTask(ContratoTaskArchive: Record "Contrato Task Archive"; var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreSingleContratoPlanningLine(ContratoPlanningLineArchive: Record "Contrato Planning Line Archive"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddCalculatedValuesToContratoTaskArchiveOnBeforeModifyContratoTaskArchive(var ContratoTask: Record "Contrato Task"; var ContratoTaskArchive: Record "Contrato Task Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddCalculatedValuesToContratoPlanningLineArchiveOnBeforeModifyContratoPlanningLineArchive(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoPlanningLineArchive: Record "Contrato Planning Line Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckContratoRestorePermissions(ContratoArchive: Record "Contrato Archive"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreSingleContratoTaskOnBeforeInsertContratoTask(var ContratoTaskArchive: Record "Contrato Task Archive"; var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreContratoPlanningLinesOnBeforeInsertContratoPlanningLine(var ContratoPlanningLineArchive: Record "Contrato Planning Line Archive"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreContratoOnBeforeInsertContrato(ContratoArchive: Record "Contrato Archive"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStoreContratoOnBeforeStoreContratoTaskAndContratoPlanningLine(var ContratoTask: Record "Contrato Task"; var ContratoPlanningLine: Record "Contrato Planning Line"; var Contrato: Record Contrato)
    begin
    end;
}

