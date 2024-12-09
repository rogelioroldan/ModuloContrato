codeunit 50229 "ContratoPlanningLine-Calendar"
{
    TableNo = "Contrato Planning Line";

    trigger OnRun()
    var
        LocalContratoPlanningLine: Record "Contrato Planning Line";
    begin
        LocalContratoPlanningLine.SetRange("Contrato No.", Rec."Contrato No.");
        LocalContratoPlanningLine.SetRange("Contrato Task No.", Rec."Contrato Task No.");
        LocalContratoPlanningLine.SetFilter("Line Type", '%1|%2', Rec."Line Type"::Budget, Rec."Line Type"::"Both Budget and Billable");
        LocalContratoPlanningLine.SetRange(Type, Rec.Type::Resource);
        LocalContratoPlanningLine.SetFilter("No.", '<>''''');
        if LocalContratoPlanningLine.FindSet() then
            repeat
                SetPlanningLine(LocalContratoPlanningLine);
                CreateAndSend();
            until LocalContratoPlanningLine.Next() = 0
        else
            Message(NoPlanningLinesMsg);
    end;

    var
        ContratoPlanningLineCalendar: Record "ContratoPlanningLine-Calendar";
        ContratoPlanningLine: Record "Contrato Planning Line";
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        Contact: Record Contact;
        Customer: Record Customer;
        ContratoManagerResource: Record Resource;
        Resource: Record Resource;

        AdditionalResourcesTxt: Label 'Additional Resources';
        SetPlanningLineErr: Label 'You must specify a Contrato planning line before you can send the appointment.';
        DateTimeFormatTxt: Label '<Year4><Month,2><Day,2>T<Hours24,2><Minutes,2><Seconds,2>', Locked = true;
        ProdIDTxt: Label '//Microsoft Corporation//Dynamics 365//EN', Locked = true;
        NoPlanningLinesMsg: Label 'There are no applicable planning lines for this action.';
        SendToCalendarTelemetryTxt: Label 'Sending Contrato planning line to calendar.', Locked = true;

    procedure SetPlanningLine(NewContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ContratoPlanningLine := NewContratoPlanningLine;
        UpdateContrato();
        UpdateContratoTask();
        UpdateResource();

        OnAfterSetPlanningLine(NewContratoPlanningLine, ContratoManagerResource);
    end;

    procedure CreateAndSend()
    var
        TempEmailItem: Record "Email Item" temporary;
        OfficeMgt: Codeunit "Office Management";
    begin
        if ContratoPlanningLine."No." = '' then
            Error(SetPlanningLineErr);

        if ContratoPlanningLineCalendar.ShouldSendCancellation(ContratoPlanningLine) then
            if CreateCancellation(TempEmailItem) then
                TempEmailItem.Send(true, Enum::"Email Scenario"::"Job Planning Line Calendar");

        if ContratoPlanningLineCalendar.ShouldSendRequest(ContratoPlanningLine) then
            if CreateRequest(TempEmailItem) then begin
                //Session.LogMessage('0000ACX', SendToCalendarTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OfficeMgt.GetOfficeAddinTelemetryCategory());
                TempEmailItem.Send(true, Enum::"Email Scenario"::"Job Planning Line Calendar");
            end;
    end;

    procedure CreateRequest(var TempEmailItem: Record "Email Item" temporary): Boolean
    var
        Email: Text[80];
    begin
        if ContratoPlanningLine."No." = '' then
            Error(SetPlanningLineErr);

        Email := GetResourceEmail(ContratoPlanningLine."No.");

        if Email <> '' then begin
            ContratoPlanningLineCalendar.InsertOrUpdate(ContratoPlanningLine);
            GenerateEmail(TempEmailItem, Email, false);
            exit(true);
        end;
    end;

    procedure CreateCancellation(var TempEmailItem: Record "Email Item" temporary): Boolean
    var
        Email: Text[80];
    begin
        if ContratoPlanningLine."No." = '' then
            Error(SetPlanningLineErr);

        if not ContratoPlanningLineCalendar.HasBeenSent(ContratoPlanningLine) then
            exit(false);

        Email := GetResourceEmail(ContratoPlanningLineCalendar."Resource No.");
        if Email <> '' then begin
            GenerateEmail(TempEmailItem, Email, true);
            ContratoPlanningLineCalendar.Delete();
            exit(true);
        end;
    end;

    local procedure GenerateEmail(var TempEmailItem: Record "Email Item" temporary; RecipientEmail: Text[80]; Cancel: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        Stream: OutStream;
        InStream: Instream;
        ICS: Text;
    begin
        //ICS := GenerateICS(Cancel);
        TempBlob.CreateOutStream(Stream, TextEncoding::UTF8);
        Stream.Write(ICS);
        TempBlob.CreateInStream(InStream);

        TempEmailItem.Initialize();
        TempEmailItem.Subject := ContratoTask.Description;
        TempEmailItem.AddAttachment(InStream, StrSubstNo('%1.ics', ContratoTask.TableCaption()));
        TempEmailItem."Send to" := RecipientEmail;
    end;

    //local procedure GenerateICS(Cancel: Boolean) ICS: Text
    // var
    //     StringBuilder: DotNet StringBuilder;
    //     Location: Text;
    //     Summary: Text;
    //     Status: Text;
    //     Method: Text;
    //     Description: Text;
    // begin
    //     Location := StrSubstNo('%1, %2, %3', Customer.Address, Customer.City, Customer."Country/Region Code");
    //     Summary := StrSubstNo('%1:%2:%3', ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No.");

    //     if Cancel then begin
    //         Method := 'CANCEL';
    //         Status := 'CANCELLED';
    //     end else begin
    //         Method := 'REQUEST';
    //         Status := 'CONFIRMED';
    //     end;
    //     Description := GetDescription();

    //     StringBuilder := StringBuilder.StringBuilder();
    //     StringBuilder.AppendLine('BEGIN:VCALENDAR');
    //     StringBuilder.AppendLine('VERSION:2.0');
    //     StringBuilder.AppendLine('PRODID:-' + ProdIDTxt);
    //     StringBuilder.AppendLine('METHOD:' + Method);
    //     StringBuilder.AppendLine('BEGIN:VEVENT');
    //     StringBuilder.AppendLine('UID:' + DelChr(ContratoPlanningLineCalendar.UID, '<>', '{}'));
    //     StringBuilder.AppendLine('ORGANIZER:' + GetOrganizer());
    //     StringBuilder.AppendLine('LOCATION:' + Location);
    //     StringBuilder.AppendLine('DTSTART:' + GetStartDate());
    //     StringBuilder.AppendLine('DTEND:' + GetEndDate());
    //     StringBuilder.AppendLine('SUMMARY:' + Summary);
    //     StringBuilder.AppendLine('DESCRIPTION:' + Description);
    //     StringBuilder.AppendLine('X-ALT-DESC;FMTTYPE=' + GetHtmlDescription(Description));
    //     StringBuilder.AppendLine('SEQUENCE:' + Format(ContratoPlanningLineCalendar.Sequence));
    //     StringBuilder.AppendLine('STATUS:' + Status);
    //     StringBuilder.AppendLine('END:VEVENT');
    //     StringBuilder.AppendLine('END:VCALENDAR');

    //     ICS := StringBuilder.ToString();
    // end;

    local procedure GetAdditionalResources() AdditionalResources: Text
    var
        LocalContratoPlanningLine: Record "Contrato Planning Line";
        LocalResource: Record Resource;
    begin
        // Get all resources for the same Contrato task.
        LocalContratoPlanningLine.SetRange("Contrato No.", ContratoPlanningLine."Contrato No.");
        LocalContratoPlanningLine.SetRange("Contrato Task No.", ContratoPlanningLine."Contrato Task No.");
        LocalContratoPlanningLine.SetRange(Type, LocalContratoPlanningLine.Type::Resource);
        LocalContratoPlanningLine.SetFilter("Line Type", '%1|%2', LocalContratoPlanningLine."Line Type"::Budget, LocalContratoPlanningLine."Line Type"::"Both Budget and Billable");
        LocalContratoPlanningLine.SetFilter("No.", '<>%1&<>''''', Resource."No.");
        if LocalContratoPlanningLine.FindSet() then begin
            AdditionalResources += '\n\n' + AdditionalResourcesTxt + ':';
            repeat
                LocalResource.Get(LocalContratoPlanningLine."No.");
                AdditionalResources +=
                    StrSubstNo('\n    (%1) %2 - %3', LocalContratoPlanningLine."Line Type", LocalResource.Name, LocalContratoPlanningLine.Description);
            until LocalContratoPlanningLine.Next() = 0;
        end;
    end;

    local procedure GetContactPhone(): Text[30]
    begin
        if Contact."No." <> '' then
            exit(Contact."Phone No.");

        exit(Customer."Phone No.");
    end;

    local procedure GetDescription() AppointmentDescription: Text
    var
        AppointmentFormat: Text;
    begin
        AppointmentFormat := Contrato.TableCaption + ': %1 - %2\r\n';
        AppointmentFormat += ContratoTask.TableCaption + ': %3 - %4\n\n';
        if Customer.Name <> '' then
            AppointmentFormat += StrSubstNo('%1: %2\n', Customer.TableCaption(), Customer.Name);
        AppointmentFormat += Contact.TableCaption + ': %5\n';
        AppointmentFormat += Contact.FieldCaption("Phone No.") + ': %6\n\n';
        AppointmentFormat += Resource.TableCaption + ': (%7) %8 - %9';
        AppointmentDescription := StrSubstNo(AppointmentFormat,
            Contrato."No.", Contrato.Description,
            ContratoTask."Contrato Task No.", ContratoTask.Description,
            Customer.Contact, GetContactPhone(),
            ContratoPlanningLine."Line Type", Resource.Name, ContratoPlanningLine.Description);

        AppointmentDescription += GetAdditionalResources();
        if ContratoManagerResource.Name <> '' then
            AppointmentDescription += StrSubstNo('\n\n%1: %2',
                Contrato.FieldCaption("Project Manager"), ContratoManagerResource.Name);
    end;

    local procedure GetHtmlDescription(Description: Text) HtmlAppointDescription: Text
    var
        Regex: Codeunit Regex;
    begin
        HtmlAppointDescription := Regex.Replace(Description, '\\r', '');
        HtmlAppointDescription := Regex.Replace(HtmlAppointDescription, '\\n', '<br>');
        HtmlAppointDescription := 'text/html:<html><body>' + HtmlAppointDescription + '</html></body>';
    end;

    local procedure GetOrganizer(): Text
    var
        ContratoManagerUser: Record User;
        EmailAccount: Record "Email Account";
        EmailScenario: Codeunit "Email Scenario";
    begin
        ContratoManagerUser.SetRange("User Name", ContratoManagerResource."Time Sheet Owner User ID");
        if ContratoManagerUser.FindFirst() then
            if ContratoManagerUser."Authentication Email" <> '' then
                exit(ContratoManagerUser."Authentication Email");

        EmailScenario.GetEmailAccount(Enum::"Email Scenario"::Default, EmailAccount);
        exit(EmailAccount."Email Address");

    end;

    local procedure GetStartDate() StartDateTime: Text
    var
        StartDate: Date;
        StartTime: Time;
    begin
        StartDate := ContratoPlanningLine."Planning Date";
        if ContratoPlanningLine.Quantity < 12 then
            Evaluate(StartTime, Format(8));

        StartDateTime := Format(CreateDateTime(StartDate, StartTime), 0, DateTimeFormatTxt);

        OnAfterGetStartDate(ContratoPlanningLine, StartDateTime);
    end;

    local procedure GetEndDate() EndDateTime: Text
    var
        StartDate: Date;
        EndTime: Time;
        Duration: Decimal;
        Days: Integer;
    begin
        Duration := ContratoPlanningLine.Quantity;
        StartDate := ContratoPlanningLine."Planning Date";
        if Duration < 12 then
            Evaluate(EndTime, Format(8 + Duration))
        else
            Days := Round(Duration / 24, 1, '>');

        EndDateTime := Format(CreateDateTime(StartDate + Days, EndTime), 0, DateTimeFormatTxt);

        OnAfterGetEndDate(ContratoPlanningLine, EndDateTime);
    end;

    local procedure GetResourceEmail(ResourceNo: Code[20]): Text[80]
    var
        LocalResource: Record Resource;
        LocalUser: Record User;
    begin
        LocalResource.Get(ResourceNo);
        LocalUser.SetRange("User Name", LocalResource."Time Sheet Owner User ID");
        if LocalUser.FindFirst() then
            exit(LocalUser."Authentication Email");
    end;

    local procedure UpdateContrato()
    begin
        if Contrato."No." <> ContratoPlanningLine."Contrato No." then begin
            Contrato.Get(ContratoPlanningLine."Contrato No.");
            Customer.Get(Contrato."Bill-to Customer No.");
            if Customer."Primary Contact No." <> '' then
                Contact.Get(Customer."Primary Contact No.");
            if Contrato."Project Manager" <> '' then
                ContratoManagerResource.Get(Contrato."Project Manager");
        end;
    end;

    local procedure UpdateContratoTask()
    begin
        if (ContratoTask."Contrato Task No." <> ContratoPlanningLine."Contrato Task No.") or (ContratoTask."Contrato No." <> ContratoPlanningLine."Contrato No.") then
            ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
    end;

    local procedure UpdateResource()
    begin
        if ContratoPlanningLine."No." <> Resource."No." then
            if ContratoPlanningLine."No." <> '' then
                Resource.Get(ContratoPlanningLine."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contrato Planning Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeletePlanningLine(var Rec: Record "Contrato Planning Line"; RunTrigger: Boolean)
    var
        LocalContratoPlanningLineCalendar: Record "ContratoPlanningLine-Calendar";
    begin
        if not RunTrigger or Rec.IsTemporary then
            exit;
        if LocalContratoPlanningLineCalendar.HasBeenSent(Rec) then begin
            SetPlanningLine(Rec);
            CreateAndSend();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPlanningLine(NewContratoPlanningLine: Record "Contrato Planning Line"; var ContratoManagerResource: Record Resource)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetStartDate(ContratoPlanningLine: Record "Contrato Planning Line"; var StartDateTime: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetEndDate(ContratoPlanningLine: Record "Contrato Planning Line"; var EndDateTime: Text)
    begin
    end;
}

