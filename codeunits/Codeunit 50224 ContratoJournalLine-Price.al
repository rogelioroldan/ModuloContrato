codeunit 50224 "Contrato Journal Line - Price" implements "Line With Price"
{
    var
        ContratoJournalLine: Record "Contrato Journal Line";
        PriceSourceList: Codeunit "Price Source List";
        CurrPriceType: Enum "Price Type";
        PriceCalculated: Boolean;
        DiscountIsAllowed: Boolean;
        IsSKU: Boolean;

    procedure GetTableNo(): Integer
    begin
        exit(Database::"Contrato Journal Line");
    end;

    procedure SetLine(PriceType: Enum "Price Type"; Line: Variant)
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        ClearAll();
        ContratoJournalLine := Line;
        CurrPriceType := PriceType;
        PriceCalculated := false;
        DiscountIsAllowed := true;
        if ContratoJournalLine.Type = ContratoJournalLine.Type::Item then
            IsSKU := StockkeepingUnit.Get(ContratoJournalLine."Location Code", ContratoJournalLine."No.", ContratoJournalLine."Variant Code");
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
        Line := ContratoJournalLine;
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
                            not (CalledByFieldNo in [ContratoJournalLine.FieldNo(Quantity), ContratoJournalLine.FieldNo("Variant Code")]);
                    CurrPriceType::Purchase:
                        Result :=
                            Result or
                            not ((CalledByFieldNo = ContratoJournalLine.FieldNo(Quantity)) or
                                ((CalledByFieldNo = ContratoJournalLine.FieldNo("Variant Code")) and not IsSKU))
                end;
        OnAfterIsPriceUpdateNeeded(AmountType, FoundPrice, CalledByFieldNo, ContratoJournalLine, Result);
    end;

    procedure IsDiscountAllowed() Result: Boolean;
    begin
        Result := DiscountIsAllowed or not PriceCalculated;
    end;

    procedure Verify()
    begin
        ContratoJournalLine.TestField("Qty. per Unit of Measure");
        if ContratoJournalLine."Currency Code" <> '' then
            ContratoJournalLine.TestField("Currency Factor");
    end;

    procedure SetAssetSourceForSetup(var DtldPriceCalculationSetup: Record "Dtld. Price Calculation Setup"): Boolean
    begin
        DtldPriceCalculationSetup.Init();
        DtldPriceCalculationSetup.Type := CurrPriceType;
        case CurrPriceType of
            CurrPriceType::Sale:
                DtldPriceCalculationSetup.Method := ContratoJournalLine."Price Calculation Method";
            CurrPriceType::Purchase:
                DtldPriceCalculationSetup.Method := ContratoJournalLine."Cost Calculation Method";
        end;
        DtldPriceCalculationSetup."Asset Type" := GetAssetType();
        DtldPriceCalculationSetup."Asset No." := ContratoJournalLine."No.";
        exit(PriceSourceList.GetSourceGroup(DtldPriceCalculationSetup));
    end;

    local procedure SetAssetSource(var PriceCalculationBuffer: Record "Price Calculation Buffer"): Boolean;
    begin
        PriceCalculationBuffer."Price Type" := CurrPriceType;
        PriceCalculationBuffer."Asset Type" := GetAssetType();
        PriceCalculationBuffer."Asset No." := ContratoJournalLine."No.";
        exit((PriceCalculationBuffer."Asset Type" <> PriceCalculationBuffer."Asset Type"::" ") and (PriceCalculationBuffer."Asset No." <> ''));
    end;

    procedure GetAssetType() AssetType: Enum "Price Asset Type";
    begin
        case ContratoJournalLine.Type of
            ContratoJournalLine.Type::Item:
                AssetType := AssetType::Item;
            ContratoJournalLine.Type::Resource:
                AssetType := AssetType::Resource;
            ContratoJournalLine.Type::"G/L Account":
                AssetType := AssetType::"G/L Account";
            else
                AssetType := AssetType::" ";
        end;
        OnAfterGetAssetType(ContratoJournalLine, AssetType);
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
        PriceCalculationBuffer."Price Calculation Method" := ContratoJournalLine."Price Calculation Method";
        PriceCalculationBuffer."Cost Calculation Method" := ContratoJournalLine."Cost Calculation Method";
        PriceCalculationBuffer."Location Code" := ContratoJournalLine."Location Code";
        case PriceCalculationBuffer."Asset Type" of
            PriceCalculationBuffer."Asset Type"::Item:
                begin
                    Item.Get(PriceCalculationBuffer."Asset No.");
                    PriceCalculationBuffer."Variant Code" := ContratoJournalLine."Variant Code";
                    PriceCalculationBuffer."Is SKU" := IsSKU;
                    PriceCalculationBuffer."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
                end;
            PriceCalculationBuffer."Asset Type"::Resource:
                begin
                    Resource.Get(PriceCalculationBuffer."Asset No.");
                    PriceCalculationBuffer."Work Type Code" := ContratoJournalLine."Work Type Code";
                    PriceCalculationBuffer."VAT Prod. Posting Group" := Resource."VAT Prod. Posting Group";
                end;
        end;
        if ContratoJournalLine."Time Sheet Date" <> 0D then
            PriceCalculationBuffer."Document Date" := ContratoJournalLine."Time Sheet Date"
        else
            PriceCalculationBuffer."Document Date" := ContratoJournalLine."Posting Date";
        if PriceCalculationBuffer."Document Date" = 0D then
            PriceCalculationBuffer."Document Date" := WorkDate();
        PriceCalculationBuffer.Validate("Currency Code", ContratoJournalLine."Currency Code");
        PriceCalculationBuffer."Currency Factor" := ContratoJournalLine."Currency Factor";

        // Tax
        PriceCalculationBuffer."Prices Including Tax" := false;
        // UoM
        PriceCalculationBuffer.Quantity := Abs(ContratoJournalLine.Quantity);
        PriceCalculationBuffer."Unit of Measure Code" := ContratoJournalLine."Unit of Measure Code";
        PriceCalculationBuffer."Qty. per Unit of Measure" := ContratoJournalLine."Qty. per Unit of Measure";
        // Discounts
        PriceCalculationBuffer."Allow Line Disc." := IsDiscountAllowed();
        PriceCalculationBuffer."Allow Invoice Disc." := false;
        OnAfterFillBuffer(PriceCalculationBuffer, ContratoJournalLine);
    end;

    local procedure AddSources()
    var
        Contrato: Record Contrato;
        SourceType: Enum "Price Source Type";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAddSources(PriceSourceList, ContratoJournalLine, CurrPriceType, IsHandled);
        if IsHandled then
            exit;

        Contrato.Get(ContratoJournalLine."Contrato No.");
        PriceSourceList.Init();
        case CurrPriceType of
            CurrPriceType::Sale:
                begin
                    PriceSourceList.Add(SourceType::"All Customers");
                    PriceSourceList.Add(SourceType::Customer, Contrato."Bill-to Customer No.");
                    PriceSourceList.Add(SourceType::Contact, Contrato."Bill-to Contact No.");
                    PriceSourceList.Add(SourceType::"Customer Price Group", ContratoJournalLine."Customer Price Group");
                    PriceSourceList.Add(SourceType::"Customer Disc. Group", Contrato."Customer Disc. Group");
                end;
            CurrPriceType::Purchase:
                PriceSourceList.Add(SourceType::"All Vendors");
        end;
        PriceSourceList.AddJobAsSources(ContratoJournalLine."Contrato No.", ContratoJournalLine."Contrato Task No.");
    end;

    procedure SetPrice(AmountType: Enum "Price Amount Type"; PriceListLine: Record "Price List Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetPrice(ContratoJournalLine, PriceListLine, AmountType, IsHandled);
        if IsHandled then
            exit;

        if AmountType = AmountType::Discount then
            ContratoJournalLine."Line Discount %" := PriceListLine."Line Discount %"
        else
            case CurrPriceType of
                CurrPriceType::Sale:
                    begin
                        ContratoJournalLine."Unit Price" := PriceListLine."Unit Price";
                        ContratoJournalLine."Cost Factor" := PriceListLine."Cost Factor";
                        if PriceListLine.IsRealLine() then
                            DiscountIsAllowed := PriceListLine."Allow Line Disc.";
                        PriceCalculated := true;
                    end;
                CurrPriceType::Purchase:
                    case ContratoJournalLine.Type of
                        ContratoJournalLine.Type::Item:
                            ContratoJournalLine."Direct Unit Cost (LCY)" := PriceListLine."Direct Unit Cost";
                        ContratoJournalLine.Type::Resource:
                            begin
                                ContratoJournalLine."Unit Cost" := PriceListLine."Unit Cost";
                                ContratoJournalLine."Direct Unit Cost (LCY)" := PriceListLine."Direct Unit Cost";
                            end;
                        ContratoJournalLine.Type::"G/L Account":
                            if PriceListLine."Unit Cost" <> 0 then
                                ContratoJournalLine."Unit Cost" := PriceListLine."Unit Cost"
                            else
                                ContratoJournalLine."Unit Cost" := PriceListLine."Direct Unit Cost";
                    end;
            end;
        OnAfterSetPrice(ContratoJournalLine, PriceListLine, AmountType);
    end;

    procedure ValidatePrice(AmountType: enum "Price Amount Type")
    begin
        if AmountType = AmountType::Discount then
            ContratoJournalLine.Validate("Line Discount %")
        else
            case CurrPriceType of
                CurrPriceType::Sale:
                    ContratoJournalLine.Validate("Unit Price");
                CurrPriceType::Purchase:
                    case ContratoJournalLine.Type of
                        ContratoJournalLine.Type::Item:
                            ContratoJournalLine.Validate("Direct Unit Cost (LCY)");
                        ContratoJournalLine.Type::Resource:
                            begin
                                ContratoJournalLine.Validate("Direct Unit Cost (LCY)");
                                ContratoJournalLine.Validate("Unit Cost (LCY)");
                            end;
                        ContratoJournalLine.Type::"G/L Account":
                            ContratoJournalLine.Validate("Unit Cost");
                    end;
            end;
    end;

    procedure Update(AmountType: enum "Price Amount Type")
    begin
        if not DiscountIsAllowed then
            ContratoJournalLine."Line Discount %" := 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillBuffer(var PriceCalculationBuffer: Record "Price Calculation Buffer"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAssetType(ContratoJournalLine: Record "Contrato Journal Line"; var AssetType: Enum "Price Asset Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsPriceUpdateNeeded(AmountType: Enum "Price Amount Type"; FoundPrice: Boolean; CalledByFieldNo: Integer; ContratoJournalLine: Record "Contrato Journal Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPrice(var ContratoJournalLine: Record "Contrato Journal Line"; PriceListLine: Record "Price List Line"; AmountType: Enum "Price Amount Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSources(var PriceSourceList: Codeunit "Price Source List"; ContratoJournalLine: Record "Contrato Journal Line"; CurrPriceType: Enum "Price Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetPrice(var ContratoJournalLine: Record "Contrato Journal Line"; PriceListLine: Record "Price List Line"; AmountType: Enum "Price Amount Type"; var IsHandled: Boolean)
    begin
    end;
}