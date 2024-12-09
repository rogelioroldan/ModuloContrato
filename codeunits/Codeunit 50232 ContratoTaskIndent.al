codeunit 50232 "Contrato Task-Indent"
{
    TableNo = "Contrato Task";

    trigger OnRun()
    var
        IsHandled: Boolean;
    begin
        Rec.TestField("Contrato No.");

        IsHandled := false;
        OnRunOnBeforeConfirm(Rec, IsHandled);
        if not IsHandled then
            if not
               Confirm(
                 Text000 +
                 Text001 +
                 Text002 +
                 Text003, true)
            then
                exit;

        ContratoTask := Rec;
        Indent(Rec."Contrato No.");
    end;

    var
        ContratoTask: Record "Contrato Task";
        Window: Dialog;
        i: Integer;

        Text000: Label 'This function updates the indentation of all the Contrato Tasks.';
        Text001: Label 'All Contrato Tasks between a Begin-Total and the matching End-Total are indented one level. ';
        Text002: Label 'The Totaling for each End-total is also updated.';
        Text003: Label '\\Do you want to indent the Contrato Tasks?';
        Text004: Label 'Indenting the Contrato Tasks #1##########.';
        Text005: Label 'End-Total %1 is missing a matching Begin-Total.';
        ArrayExceededErr: Label 'You can only indent %1 levels for Contrato tasks of the type Begin-Total.', Comment = '%1 = A number bigger than 1';

    procedure Indent(ContratoNo: Code[20])
    var
        SelectionFilterManagement: Codeunit "SelectionFilterManagement";
        ContratoTaskNo: array[10] of Text;
    begin
        Window.Open(Text004);
        ContratoTask.SetRange("Contrato No.", ContratoNo);
        if ContratoTask.Find('-') then
            repeat
                Window.Update(1, ContratoTask."Contrato Task No.");

                if ContratoTask."Contrato Task Type" = "Contrato Task Type"::"End-Total" then begin
                    if i < 1 then
                        Error(
                            Text005,
                            ContratoTask."Contrato Task No.");

                    ContratoTask.Totaling := ContratoTaskNo[i] + '..' + SelectionFilterManagement.AddQuotes(ContratoTask."Contrato Task No.");
                    i := i - 1;
                end;

                ContratoTask.Indentation := i;
                OnBeforeContratoTaskModify(ContratoTask, ContratoNo);
                ContratoTask.Modify();

                if ContratoTask."Contrato Task Type" = "Contrato Task Type"::"Begin-Total" then begin
                    i := i + 1;
                    if i > ArrayLen(ContratoTaskNo) then
                        Error(ArrayExceededErr, ArrayLen(ContratoTaskNo));
                    ContratoTaskNo[i] := SelectionFilterManagement.AddQuotes(ContratoTask."Contrato Task No.");
                end;
            until ContratoTask.Next() = 0;

        Window.Close();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoTaskModify(var ContratoTask: Record "Contrato Task"; ContratoNo: Code[20]);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeConfirm(var ContratoTask: Record "Contrato Task"; var IsHandled: Boolean)
    begin
    end;
}

