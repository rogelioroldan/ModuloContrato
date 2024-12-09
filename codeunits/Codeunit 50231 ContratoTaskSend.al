codeunit 50231 "Contrato Tasks-Send"
{
    TableNo = "Contrato Task";

    trigger OnRun()
    begin
        ContratoTask.Copy(Rec);
        Code();
        Rec := ContratoTask;
    end;

    var
        ContratoTask: Record "Contrato Task";
        ContratoArchiveManagement: Codeunit "Contrato Archive Management";

    local procedure "Code"()
    var
        Contrato: Record "Contrato";
        TempDocumentSendingProfile: Record "Document Sending Profile" temporary;
    begin
        if not ConfirmSend(ContratoTask, TempDocumentSendingProfile) then
            exit;

        ValidateElectronicFormats(TempDocumentSendingProfile);

        ContratoTask.Get(ContratoTask."Contrato No.", ContratoTask."Contrato Task No.");
        ContratoTask.SetRecFilter();
        ContratoTask.SendProfile(TempDocumentSendingProfile);
        Contrato.Get(ContratoTask."Contrato No.");
        ContratoArchiveManagement.AutoArchiveContrato(Contrato);
    end;

    local procedure ConfirmSend(ContratoTask: Record "Contrato Task"; var TempDocumentSendingProfile: Record "Document Sending Profile" temporary): Boolean
    var
        Customer: Record Customer;
        DocumentSendingProfile: Record "Document Sending Profile";
        OfficeMgt: Codeunit "Office Management";
    begin
        Customer.Get(ContratoTask."Bill-to Customer No.");
        if OfficeMgt.IsAvailable() then
            DocumentSendingProfile.GetOfficeAddinDefault(TempDocumentSendingProfile, OfficeMgt.AttachAvailable())
        else begin
            if not DocumentSendingProfile.Get(Customer."Document Sending Profile") then
                DocumentSendingProfile.GetDefault(DocumentSendingProfile);

            Commit();
            TempDocumentSendingProfile.Copy(DocumentSendingProfile);
            TempDocumentSendingProfile.SetDocumentUsage(ContratoTask);
            TempDocumentSendingProfile.Insert();
            if PAGE.RunModal(PAGE::"Post and Send Confirmation", TempDocumentSendingProfile) <> ACTION::Yes then
                exit(false);
        end;

        exit(true);
    end;

    local procedure ValidateElectronicFormats(DocumentSendingProfile: Record "Document Sending Profile")
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        if (DocumentSendingProfile."E-Mail" <> DocumentSendingProfile."E-Mail"::No) and
           (DocumentSendingProfile."E-Mail Attachment" <> DocumentSendingProfile."E-Mail Attachment"::PDF)
        then begin
            //     ElectronicDocumentFormat.ValidateElectronicFormat(DocumentSendingProfile."E-Mail Format");
            //     ElectronicDocumentFormat.ValidateElectronicJobTasksDocument(ContratoTask, DocumentSendingProfile."E-Mail Format");
        end;

        if (DocumentSendingProfile.Disk <> DocumentSendingProfile.Disk::No) and
           (DocumentSendingProfile.Disk <> DocumentSendingProfile.Disk::PDF)
        then begin
            // ElectronicDocumentFormat.ValidateElectronicFormat(DocumentSendingProfile."Disk Format");
            // ElectronicDocumentFormat.ValidateElectronicJobTasksDocument(ContratoTask, DocumentSendingProfile."Disk Format");
        end;

        // if DocumentSendingProfile."Electronic Document" <> DocumentSendingProfile."Electronic Document"::No then begin
        //     ElectronicDocumentFormat.ValidateElectronicFormat(DocumentSendingProfile."Electronic Format");
        //     ElectronicDocumentFormat.ValidateElectronicJobTasksDocument(ContratoTask, DocumentSendingProfile."Electronic Format");
        // end;
    end;
}

