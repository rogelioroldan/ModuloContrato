codeunit 50227 "Price Source - Contrato" implements "Price Source"
{
    var
        Contrato: Record Contrato;
        ParentErr: Label 'Parent Source No. must be blank for Contrato source type.';

    procedure GetNo(var PriceSource: Record "Price Source")
    begin
        if Contrato.GetBySystemId(PriceSource."Source ID") then begin
            PriceSource."Source No." := Contrato."No.";
            FillAdditionalFields(PriceSource);
        end else
            PriceSource.InitSource();
    end;

    procedure GetId(var PriceSource: Record "Price Source")
    begin
        if Contrato.Get(PriceSource."Source No.") then begin
            PriceSource."Source ID" := Contrato.SystemId;
            FillAdditionalFields(PriceSource);
        end else
            PriceSource.InitSource();
    end;

    procedure IsForAmountType(AmountType: Enum "Price Amount Type"): Boolean
    begin
        exit(true);
    end;

    procedure IsSourceNoAllowed() Result: Boolean;
    begin
        Result := true;
    end;

    procedure IsLookupOK(var PriceSource: Record "Price Source"): Boolean
    var
        xPriceSource: Record "Price Source";
    begin
        xPriceSource := PriceSource;
        if Contrato.Get(xPriceSource."Source No.") then;
        if Page.RunModal(Page::"Contrato List", Contrato) = ACTION::LookupOK then begin
            xPriceSource.Validate("Source No.", Contrato."No.");
            PriceSource := xPriceSource;
            exit(true);
        end;
    end;

    procedure VerifyParent(var PriceSource: Record "Price Source") Result: Boolean
    begin
        if PriceSource."Parent Source No." <> '' then
            Error(ParentErr);
    end;

    procedure GetGroupNo(PriceSource: Record "Price Source"): Code[20];
    begin
        exit(PriceSource."Source No.");
    end;

    local procedure FillAdditionalFields(var PriceSource: Record "Price Source")
    begin
        PriceSource.Description := Contrato.Description;
        PriceSource."Currency Code" := Contrato."Currency Code";
        OnAfterFillAdditionalFields(PriceSource, Contrato);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Source List", 'OnBeforeAddChildren', '', false, false)]
    local procedure AddChildren(var Sender: Codeunit "Price Source List"; PriceSource: Record "Price Source"; var TempChildPriceSource: Record "Price Source" temporary);
    var
        ContratoTask: Record "Contrato Task";
    begin
        if PriceSource."Source Type" = "Price Source Type"::Contrato then begin
            ContratoTask.SetRange("Contrato Task Type", ContratoTask."Contrato Task Type"::Posting);
            ContratoTask.SetRange("Contrato No.", PriceSource."Source No.");
            if ContratoTask.FindSet() then
                repeat
                    ContratoTask.ToPriceSource(TempChildPriceSource, PriceSource."Price Type");
                    TempChildPriceSource."Entry No." += 1;
                    TempChildPriceSource.Insert();
                until ContratoTask.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillAdditionalFields(var PriceSource: Record "Price Source"; Contrato: Record Contrato)
    begin
    end;
}