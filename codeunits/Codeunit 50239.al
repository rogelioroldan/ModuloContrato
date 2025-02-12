codeunit 50239 "Approvals Mgmt. Contrato"
{
    Subtype = Normal;

    procedure CheckContratoQueueEntryApprovalEnabled(): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin

        exit(WorkflowManagement.EnabledWorkflowExist(Database::"Contrato Queue Entry", WorkflowEventHandling.RunWorkflowOnSendJobQueueEntryForApprovalCode()));
    end;

    procedure OnSendContratoQueueEntryForApproval(var JobQueueEntry: Record "Contrato Queue Entry")
    begin
    end;
}
