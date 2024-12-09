codeunit 50218 "Contrato Planning Line - Price" implements "Line With Price"
{
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        PriceSourceList: Codeunit "Price Source List";
        CurrPriceType: Enum "Price Type";
        PriceCalculated: Boolean;
        DiscountIsAllowed: Boolean;
        IsSKU: Boolean;

    procedure GetTableNo(): Integer
    begin
        exit(Database::"Contrato Planning Line")
    end;

    procedure SetLine(PriceType: Enum "Price Type"; Line: Variant)
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        ClearAll();
        ContratoPlanningLine := Line;
        CurrPriceType := PriceType;
        PriceCalculated := false;
        DiscountIsAllowed := true;
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Item then
            IsSKU := StockkeepingUnit.Get(ContratoPlanningLine."Location Code", ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code");
        AddSources();
    end;

    procedure SetLine(PriceType: Enum "Price Type"; Header: Variant; Line: Variant)
    begin
        Setline(PriceType, Line);
    end;

    procedure SetSources(var NewPriceSourceList: codeunit "Price Source List")
    begin
        PriceSourceList.Copy(NewPriceSourceList);
    end;

    procedure GetLine(var Line: Variant)
    begin
        Line := ContratoPlanningLine;
    end;

    procedure GetLine(var Header: Variant; var Line: Variant)
    begin
        Clear(Header);
        GetLine(Line);
    end;

    procedure GetPriceType(): Enum "Price Type"
    begin
        exit(CurrPriceType);
    end;

    procedure IsPriceUpdateNeeded(AmountType: Enum "Price Amount Type"; FoundPrice: Boolean; CalledByFieldNo: Integer) Result: Boolean;
    begin
        if FoundPrice then
            Result := true
        else
            if AmountType <> AmountType::Discount then
                case CurrPriceType of
                    CurrPriceType::Sale:
                        Result :=
                            Result or
                            not (CalledByFieldNo in [ContratoPlanningLine.FieldNo(Quantity), ContratoPlanningLine.FieldNo("Location Code"), ContratoPlanningLine.FieldNo("Variant Code")]);
                    CurrPriceType::Purchase:
                        Result :=
                            Result or
                            not ((CalledByFieldNo = ContratoPlanningLine.FieldNo(Quantity)) or
                                ((CalledByFieldNo = ContratoPlanningLine.FieldNo("Variant Code")) and not IsSKU))
                end;
        OnAfterIsPriceUpdateNeeded(AmountType, FoundPrice, CalledByFieldNo, ContratoPlanningLine, Result);
    end;

    procedure IsDiscountAllowed() Result: Boolean;
    begin
        Result := DiscountIsAllowed or not PriceCalculated;
    end;

    procedure Verify()
    begin
        ContratoPlanningLine.TestField("Qty. per Unit of Measure");
        if ContratoPlanningLine."Currency Code" <> '' then
            ContratoPlanningLine.TestField("Currency Factor");
    end;

    procedure SetAssetSourceForSetup(var DtldPriceCalculationSetup: Record "Dtld. Price Calculation Setup"): Boolean
    begin
        DtldPriceCalculationSetup.Init();
        DtldPriceCalculationSetup.Type := CurrPriceType;
        DtldPriceCalculationSetup.Method := ContratoPlanningLine."Price Calculation Method";
        DtldPriceCalculationSetup."Asset Type" := GetAssetType();
        DtldPriceCalculationSetup."Asset No." := ContratoPlanningLine."No.";
        exit(PriceSourceList.GetSourceGroup(DtldPriceCalculationSetup));
    end;

    local procedure SetAssetSource(var PriceCalculationBuffer: Record "Price Calculation Buffer"): Boolean;
    begin
        PriceCalculationBuffer."Price Type" := CurrPriceType;
        PriceCalculationBuffer."Asset Type" := GetAssetType();
        PriceCalculationBuffer."Asset No." := ContratoPlanningLine."No.";
        exit((PriceCalculationBuffer."Asset Type" <> PriceCalculationBuffer."Asset Type"::" ") and (PriceCalculationBuffer."Asset No." <> ''));
    end;

    procedure GetAssetType() AssetType: Enum "Price Asset Type";
    begin
        case ContratoPlanningLine.Type of
            ContratoPlanningLine.Type::Item:
                AssetType := AssetType::Item;
            ContratoPlanningLine.Type::Resource:
                AssetType := AssetType::Resource;
            ContratoPlanningLine.Type::"G/L Account":
                AssetType := AssetType::"G/L Account";
            else
                AssetType := AssetType::" ";
        end;
        OnAfterGetAssetType(ContratoPlanningLine, AssetType);
    end;

    procedure CopyToBuffer(var PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt."): Boolean
    var
        PriceCalculationBuffer: Record "Price Calculation Buffer";
    begin
        PriceCalculationBuffer.Init();
        if not SetAssetSource(PriceCalculationBuffer) then
            exit(false);

        FillBuffer(PriceCalculationBuffer);
        PriceCalculationBufferMgt.Set(PriceCalculationBuffer, PriceSourceList);
        exit(true);
    end;

    local procedure FillBuffer(var PriceCalculationBuffer: Record "Price Calculation Buffer")
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        PriceCalculationBuffer."Price Calculation Method" := ContratoPlanningLine."Price Calculation Method";
        PriceCalculationBuffer."Cost Calculation Method" := ContratoPlanningLine."Cost Calculation Method";
        PriceCalculationBuffer."Location Code" := ContratoPlanningLine."Location Code";
        case PriceCalculationBuffer."Asset Type" of
            PriceCalculationBuffer."Asset Type"::Item:
                begin
                    Item.Get(PriceCalculationBuffer."Asset No.");
                    PriceCalculationBuffer."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
                    PriceCalculationBuffer."Variant Code" := ContratoPlanningLine."Variant Code";
                    PriceCalculationBuffer."Is SKU" := IsSKU;
                end;
            PriceCalculationBuffer."Asset Type"::Resource:
                begin
                    Resource.Get(PriceCalculationBuffer."Asset No.");
                    PriceCalculationBuffer."VAT Prod. Posting Group" := Resource."VAT Prod. Posting Group";
                    PriceCalculationBuffer."Work Type Code" := ContratoPlanningLine."Work Type Code";
                end;
        end;
        PriceCalculationBuffer."Document Date" := ContratoPlanningLine."Planning Date";
        if PriceCalculationBuffer."Document Date" = 0D then
            PriceCalculationBuffer."Document Date" := WorkDate();
        PriceCalculationBuffer.Validate("Currency Code", ContratoPlanningLine."Currency Code");
        PriceCalculationBuffer."Currency Factor" := ContratoPlanningLine."Currency Factor";

        // Tax
        PriceCalculationBuffer."Prices Including Tax" := false;
        // UoM
        PriceCalculationBuffer.Quantity := Abs(ContratoPlanningLine.Quantity);
        PriceCalculationBuffer."Unit of Measure Code" := ContratoPlanningLine."Unit of Measure Code";
        PriceCalculationBuffer."Qty. per Unit of Measure" := ContratoPlanningLine."Qty. per Unit of Measure";
        // Discounts
        PriceCalculationBuffer."Allow Line Disc." := IsDiscountAllowed();
        PriceCalculationBuffer."Allow Invoice Disc." := false;
        OnAfterFillBuffer(PriceCalculationBuffer, ContratoPlanningLine);
    end;

    local procedure AddSources()
    var
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        SourceType: Enum "Price Source Type";
    begin
        Contrato.Get(ContratoPlanningLine."Contrato No.");
        PriceSourceList.Init();
        case CurrPriceType of
            CurrPriceType::Sale:
                begin
                    PriceSourceList.Add(SourceType::"All Customers");
                    if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
                        PriceSourceList.Add(SourceType::Customer, Contrato."Bill-to Customer No.");
                        PriceSourceList.Add(SourceType::Contact, Contrato."Bill-to Contact No.");
                    end else begin
                        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
                        PriceSourceList.Add(SourceType::Customer, ContratoTask."Bill-to Customer No.");
                        PriceSourceList.Add(SourceType::Contact, ContratoTask."Bill-to Contact No.");
                    end;
                    PriceSourceList.Add(SourceType::"Customer Price Group", ContratoPlanningLine."Customer Price Group");
                    PriceSourceList.Add(SourceType::"Customer Disc. Group", Contrato."Customer Disc. Group");
                end;
            CurrPriceType::Purchase:
                PriceSourceList.Add(SourceType::"All Vendors");
        end;
        PriceSourceList.AddJobAsSources(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");

        OnAfterAddSources(ContratoPlanningLine, CurrPriceType, PriceSourceList, Contrato)
    end;

    procedure SetPrice(AmountType: enum "Price Amount Type"; PriceListLine: Record "Price List Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetPrice(ContratoPlanningLine, PriceListLine, AmountType, IsHandled, CurrPriceType);
        if IsHandled then
            exit;

        if AmountType = AmountType::Discount then
            ContratoPlanningLine."Line Discount %" := PriceListLine."Line Discount %"
        else
            case CurrPriceType of
                CurrPriceType::Sale:
                    begin
                        ContratoPlanningLine."Unit Price" := PriceListLine."Unit Price";
                        ContratoPlanningLine."Cost Factor" := PriceListLine."Cost Factor";
                        if PriceListLine.IsRealLine() then
                            DiscountIsAllowed := PriceListLine."Allow Line Disc.";
                        PriceCalculated := true;
                    end;
                CurrPriceType::Purchase:
                    case ContratoPlanningLine.Type of
                        ContratoPlanningLine.Type::Item:
                            ContratoPlanningLine."Direct Unit Cost (LCY)" := PriceListLine."Direct Unit Cost";
                        ContratoPlanningLine.Type::Resource:
                            begin
                                ContratoPlanningLine."Unit Cost" := PriceListLine."Unit Cost";
                                ContratoPlanningLine."Direct Unit Cost (LCY)" := PriceListLine."Direct Unit Cost";
                            end;
                        ContratoPlanningLine.Type::"G/L Account":
                            if PriceListLine."Unit Cost" <> 0 then
                                ContratoPlanningLine."Unit Cost" := PriceListLine."Unit Cost"
                            else
                                if PriceListLine."Direct Unit Cost" <> 0 then
                                    ContratoPlanningLine."Unit Cost" := PriceListLine."Direct Unit Cost";
                    end;
            end;
        OnAfterSetPrice(ContratoPlanningLine, PriceListLine, AmountType);
    end;

    procedure ValidatePrice(AmountType: enum "Price Amount Type")
    begin
        if AmountType = AmountType::Discount then
            ContratoPlanningLine.Validate("Line Discount %")
        else
            case CurrPriceType of
                CurrPriceType::Sale:
                    ContratoPlanningLine.Validate("Unit Price");
                CurrPriceType::Purchase:
                    case ContratoPlanningLine.Type of
                        ContratoPlanningLine.Type::Item:
                            ContratoPlanningLine.Validate("Direct Unit Cost (LCY)");
                        ContratoPlanningLine.Type::Resource:
                            begin
                                ContratoPlanningLine.Validate("Direct Unit Cost (LCY)");
                                ContratoPlanningLine.Validate("Unit Cost (LCY)");
                            end;
                        ContratoPlanningLine.Type::"G/L Account":
                            ContratoPlanningLine.Validate("Unit Cost");
                    end;
            end;
    end;

    procedure Update(AmountType: enum "Price Amount Type")
    begin
        if not DiscountIsAllowed then
            ContratoPlanningLine."Line Discount %" := 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillBuffer(var PriceCalculationBuffer: Record "Price Calculation Buffer"; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAssetType(ContratoPlanningLine: Record "Contrato Planning Line"; var AssetType: Enum "Price Asset Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsPriceUpdateNeeded(AmountType: Enum "Price Amount Type"; FoundPrice: Boolean; CalledByFieldNo: Integer; ContratoPlanningLine: Record "Contrato Planning Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPrice(var ContratoPlanningLine: Record "Contrato Planning Line"; PriceListLine: Record "Price List Line"; AmountType: Enum "Price Amount Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetPrice(var ContratoPlanningLine: Record "Contrato Planning Line"; PriceListLine: Record "Price List Line"; AmountType: Enum "Price Amount Type"; var IsHandled: Boolean; CurrPriceType: Enum "Price Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSources(var ContratoPlanningLine: Record "Contrato Planning Line"; CurrPriceType: Enum "Price Type"; var PriceSourceList: Codeunit "Price Source List"; Contrato: Record Contrato)
    begin
    end;
}