codeunit 50228 "Contratos-Send"
{
    TableNo = Contrato;

    trigger OnRun()
    begin
        Contrato.Copy(Rec);
        Code();
        Rec := Contrato;
    end;

    var
        Contrato: Record Contrato;
        ContratoArchiveManagement: Codeunit "Contrato Archive Management";

    local procedure "Code"()
    var
        TempDocumentSendingProfile: Record "Document Sending Profile" temporary;
    begin
        if not ConfirmSend(Contrato, TempDocumentSendingProfile) then
            exit;

        ValidateElectronicFormats(TempDocumentSendingProfile);

        Contrato.Get(Contrato."No.");
        Contrato.SetRecFilter();
        Contrato.SendProfile(TempDocumentSendingProfile);
        ContratoArchiveManagement.AutoArchiveContrato(Contrato);
    end;

    local procedure ConfirmSend(Contrato: Record Contrato; var TempDocumentSendingProfile: Record "Document Sending Profile" temporary): Boolean
    var
        Customer: Record Customer;
        DocumentSendingProfile: Record "Document Sending Profile";
        OfficeMgt: Codeunit "Office Management";
    begin
        Customer.Get(Contrato."Bill-to Customer No.");
        if OfficeMgt.IsAvailable() then
            DocumentSendingProfile.GetOfficeAddinDefault(TempDocumentSendingProfile, OfficeMgt.AttachAvailable())
        else begin
            if not DocumentSendingProfile.Get(Customer."Document Sending Profile") then
                DocumentSendingProfile.GetDefault(DocumentSendingProfile);

            Commit();
            TempDocumentSendingProfile.Copy(DocumentSendingProfile);
            TempDocumentSendingProfile.SetDocumentUsage(Contrato);
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
            ElectronicDocumentFormat.ValidateElectronicFormat(DocumentSendingProfile."E-Mail Format");
            //ElectronicDocumentFormat.ValidateElectronicJobsDocument(Contrato, DocumentSendingProfile."E-Mail Format");
        end;

        if (DocumentSendingProfile.Disk <> DocumentSendingProfile.Disk::No) and
           (DocumentSendingProfile.Disk <> DocumentSendingProfile.Disk::PDF)
        then begin
            ElectronicDocumentFormat.ValidateElectronicFormat(DocumentSendingProfile."Disk Format");
            //ElectronicDocumentFormat.ValidateElectronicJobsDocument(Contrato, DocumentSendingProfile."Disk Format");
        end;

        if DocumentSendingProfile."Electronic Document" <> DocumentSendingProfile."Electronic Document"::No then begin
            ElectronicDocumentFormat.ValidateElectronicFormat(DocumentSendingProfile."Electronic Format");
            //ElectronicDocumentFormat.ValidateElectronicJobsDocument(Contrato, DocumentSendingProfile."Electronic Format");
        end;
    end;
}

