
table 50201 "Contrato Planning Line"
{
    Caption = 'Contrato Planning Line';
    DrillDownPageID = "Contrato Planning Lines";
    LookupPageID = "Contrato Planning Lines";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(2; "Contrato No."; Code[20])
        {
            Caption = 'contrato No.';
            NotBlank = true;
            TableRelation = Contrato;
        }
        field(3; "Planning Date"; Date)
        {
            Caption = 'Planning Date';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePlanningDate(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                ValidateModification(xRec."Planning Date" <> "Planning Date", Rec.FieldNo("Planning Date"));

                Validate("Document Date", "Planning Date");
                if ("Currency Date" = 0D) or ("Currency Date" = xRec."Planning Date") then
                    Validate("Currency Date", "Planning Date");
                if (Type <> Type::Text) and ("No." <> '') then
                    UpdateAllAmounts();
                if "Planning Date" <> 0D then
                    CheckItemAvailable(FieldNo("Planning Date"));
                if CurrFieldNo = FieldNo("Planned Delivery Date") then
                    UpdateReservation(CurrFieldNo)
                else
                    UpdateReservation(FieldNo("Planning Date"));
                "Planned Delivery Date" := "Planning Date";

                UpdatePlannedDueDate();
            end;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';

            trigger OnValidate()
            begin
                ValidateModification(xRec."Document No." <> "Document No.", Rec.FieldNo("Document No."));
            end;
        }
        field(5; Type; Enum "Contrato Planning Line Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                ValidateModification(xRec.Type <> Type, Rec.FieldNo(Type));

                UpdateReservation(FieldNo(Type));

                Validate("No.", '');
                if Type = Type::Item then begin
                    GetLocation("Location Code");
                    Location.TestField("Directed Put-away and Pick", false);
                end;
            end;
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(Resource)) Resource
            else
            if (Type = const(Item)) Item where(Blocked = const(false))
            else
            if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const(Text)) "Standard Text";

            trigger OnValidate()
            begin
                ValidateModification(xRec."No." <> "No.", Rec.FieldNo("No."));

                CheckUsageLinkRelations();

                UpdateReservation(FieldNo("No."));

                UpdateDescription();

                if ("No." = '') or ("No." <> xRec."No.") then begin
                    "Unit of Measure Code" := '';
                    "Qty. per Unit of Measure" := 1;
                    "Variant Code" := '';
                    "Work Type Code" := '';
                    "Gen. Bus. Posting Group" := '';
                    "Gen. Prod. Posting Group" := '';
                    DeleteAmounts();
                    "Cost Factor" := 0;
                    if Type = Type::Item then begin
                        "Bin Code" := '';
                        if "No." <> '' then
                            InitLocation();
                        if "Bin Code" = '' then
                            SetDefaultBin();
                        //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo("No."));
                    end;
                    if "No." = '' then
                        exit;
                end;

                CopyFieldsFromContrato();

                case Type of
                    Type::Resource:
                        CopyFromResource();
                    Type::Item:
                        CopyFromItem();
                    Type::"G/L Account":
                        CopyFromGLAccount();
                    Type::Text:
                        CopyFromStandardText();
                end;

                InitQtyToAsm();

                OnValidateNoOnAfterCopyFromAccount(Rec, xRec, Contrato);

                if Type <> Type::Text then
                    Validate(Quantity);
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                ValidateModification(xRec.Description <> Description, Rec.FieldNo(Description));
            end;
        }
        field(9; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if (Quantity <> 0) and (Type = Type::Text) then
                    FieldError(Type);

                CheckQuantityPosted();

                CalcFields("Qty. Transferred to Invoice");
                if ("Qty. Transferred to Invoice" > 0) and (Quantity < "Qty. Transferred to Invoice") then
                    Error(QtyLessErr, FieldCaption(Quantity), FieldCaption("Qty. Transferred to Invoice"));
                if ("Qty. Transferred to Invoice" < 0) and (Quantity > "Qty. Transferred to Invoice") then
                    Error(QtyGreaterErr, FieldCaption(Quantity), FieldCaption("Qty. Transferred to Invoice"));

                case Type of
                    Type::Item:
                        if not Item.Get("No.") then
                            Error(MissingItemResourceGLErr, Type, Item.FieldCaption("No."));
                    Type::Resource:
                        if not Res.Get("No.") then
                            Error(MissingItemResourceGLErr, Type, Res.FieldCaption("No."));
                    Type::"G/L Account":
                        if not GLAcc.Get("No.") then
                            Error(MissingItemResourceGLErr, Type, GLAcc.FieldCaption("No."));
                end;

                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));

                CalcQuantityBase();

                "Completely Picked" := "Qty. Picked" >= Quantity;

                UpdateRemainingQuantity();

                UpdateQtyToTransfer();
                UpdateQtyToInvoice();

                CheckItemAvailable(FieldNo(Quantity));
                UpdateReservation(FieldNo(Quantity));

                UpdateAllAmounts();

                InitQtyToAsm();
                if "Line Type" in ["Line Type"::"Both Budget and Billable", "Line Type"::Budget] then
                    Validate("Qty. to Assemble");

                if not BypassQtyValidation then
                    //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo(Quantity));

                BypassQtyValidation := false;
            end;
        }
        field(10; "GrupoFacturar"; Enum "Grupo Facturar")
        {
            Caption = 'Grupo a facturar';
        }
        field(11; "Direct Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost (LCY)';

            trigger OnValidate()
            begin
                if ("Direct Unit Cost (LCY)" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
            end;
        }
        field(12; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Unit Cost (LCY)" <> "Unit Cost (LCY)", Rec.FieldNo("Unit Cost (LCY)"));

                if ("Unit Cost (LCY)" <> 0) and (Type = Type::Text) then
                    FieldError(Type);

                if (Type = Type::Item) and
                   Item.Get("No.") and
                   (Item."Costing Method" = Item."Costing Method"::Standard)
                then
                    UpdateAllAmounts()
                else begin
                    InitRoundingPrecisions();
                    "Unit Cost" := ConvertAmountToFCY("Unit Cost (LCY)", UnitAmountRoundingPrecisionFCY);
                    UpdateAllAmounts();
                end;
            end;
        }
        field(13; "Total Cost (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Total Cost (LCY)';
            Editable = false;
        }
        field(14; "Unit Price (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Unit Price (LCY)" <> "Unit Price (LCY)", Rec.FieldNo("Unit Price (LCY)"));
                if ("Unit Price (LCY)" <> 0) and (Type = Type::Text) then
                    FieldError(Type);

                InitRoundingPrecisions();
                "Unit Price" := ConvertAmountToFCY("Unit Price (LCY)", UnitAmountRoundingPrecisionFCY);
                UpdateAllAmounts();
            end;
        }
        field(15; "Total Price (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Total Price (LCY)';
            Editable = false;
        }
        field(16; "Resource Group No."; Code[20])
        {
            Caption = 'Resource Group No.';
            Editable = false;
            TableRelation = "Resource Group";
        }
        field(17; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = if (Type = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."))
            else
            if (Type = const(Resource)) "Resource Unit of Measure".Code where("Resource No." = field("No."))
            else
            "Unit of Measure";

            trigger OnValidate()
            var
                Resource: Record Resource;
            begin
                ValidateModification(xRec."Unit of Measure Code" <> "Unit of Measure Code", Rec.FieldNo("Unit of Measure Code"));

                GetGLSetup();
                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            "Qty. per Unit of Measure" :=
                              UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                            "Qty. Rounding Precision" := UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code");
                            "Qty. Rounding Precision (Base)" := UOMMgt.GetQtyRoundingPrecision(Item, Item."Base Unit of Measure");
                            //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo("Unit of Measure Code"));
                        end;
                    Type::Resource:
                        begin
                            if CurrFieldNo <> FieldNo("Work Type Code") then
                                if "Work Type Code" <> '' then begin
                                    WorkType.Get("Work Type Code");
                                    if WorkType."Unit of Measure Code" <> '' then
                                        TestField("Unit of Measure Code", WorkType."Unit of Measure Code");
                                end else
                                    TestField("Work Type Code", '');
                            if "Unit of Measure Code" = '' then begin
                                Resource.Get("No.");
                                "Unit of Measure Code" := Resource."Base Unit of Measure";
                            end;
                            ResourceUnitOfMeasure.Get("No.", "Unit of Measure Code");
                            "Qty. per Unit of Measure" := ResourceUnitOfMeasure."Qty. per Unit of Measure";
                            "Quantity (Base)" := Quantity * "Qty. per Unit of Measure";
                        end;
                    Type::"G/L Account":
                        "Qty. per Unit of Measure" := 1;
                end;
                CheckItemAvailable(FieldNo("Unit of Measure Code"));
                UpdateReservation(FieldNo("Unit of Measure Code"));
                Validate(Quantity);
            end;
        }
        field(18; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(19; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));

            trigger OnValidate()
            begin
                ValidateModification(xRec."Location Code" <> "Location Code", Rec.FieldNo("Location Code"));

                "Bin Code" := '';
                if Type = Type::Item then begin
                    GetLocation("Location Code");
                    EnsureDirectedPutawayandPickFalse(Location);
                    CheckItemAvailable(FieldNo("Location Code"));
                    UpdateReservation(FieldNo("Location Code"));
                    Validate(Quantity);
                    SetDefaultBin();
                    //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo("Location Code"));
                    InitQtyToAsm();
                    //ATOLink.UpdateAsmFromContratoPlanningLine(Rec);

                    DeleteWarehouseRequest(xRec);
                    CreateWarehouseRequest();
                end;
            end;
        }
        field(29; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(30; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(32; "Work Type Code"; Code[10])
        {
            Caption = 'Work Type Code';
            TableRelation = "Work Type";

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateWorkTypeCode(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                ValidateModification(xRec."Work Type Code" <> "Work Type Code", Rec.FieldNo("Work Type Code"));
                TestField(Type, Type::Resource);

                Validate("Line Discount %", 0);
                if ("Work Type Code" = '') and (xRec."Work Type Code" <> '') then begin
                    Res.Get("No.");
                    "Unit of Measure Code" := Res."Base Unit of Measure";
                    Validate("Unit of Measure Code");
                end;
                if WorkType.Get("Work Type Code") then
                    if WorkType."Unit of Measure Code" <> '' then begin
                        "Unit of Measure Code" := WorkType."Unit of Measure Code";
                        if ResourceUnitOfMeasure.Get("No.", "Unit of Measure Code") then
                            "Qty. per Unit of Measure" := ResourceUnitOfMeasure."Qty. per Unit of Measure";
                    end else begin
                        Res.Get("No.");
                        "Unit of Measure Code" := Res."Base Unit of Measure";
                        Validate("Unit of Measure Code");
                    end;
                Validate(Quantity);
            end;
        }
        field(33; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";

            trigger OnValidate()
            begin
                if (Type = Type::Item) and ("No." <> '') then
                    UpdateAllAmounts();
            end;
        }
        field(79; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
            TableRelation = "Country/Region";
        }
        field(80; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Editable = false;
            TableRelation = "Gen. Business Posting Group";
        }
        field(81; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            Editable = false;
            TableRelation = "Gen. Product Posting Group";
        }
        field(83; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(84; "Planning Due Date"; Date)
        {
            Caption = 'Planning Due Date';

            trigger OnValidate()
            begin
                //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo("Planning Due Date"));
            end;
        }
        field(900; "Qty. to Assemble"; Decimal)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Qty. to Assemble';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Line Type" = "Line Type"::Billable then
                    FieldError("Line Type");

                if ("Qty. to Assemble" <> Quantity) and ("Qty. to Assemble" <> 0) and WhsePickReqForLocation() then
                    FieldError("Qty. to Assemble", StrSubstNo(DifferentQtyToAssembleErr, FieldCaption(Quantity)));

                "Qty. to Assemble" := UOMMgt.RoundAndValidateQty("Qty. to Assemble", "Qty. Rounding Precision", FieldCaption("Qty. to Assemble"));
                "Qty. to Assemble (Base)" := CalcBaseQty("Qty. to Assemble", FieldCaption("Qty. to Assemble"), FieldCaption("Qty. to Assemble (Base)"));

                if "Qty. to Assemble (Base)" < 0 then
                    FieldError("Qty. to Assemble", NegativeQtyToAssembleErr);

                CheckItemAvailable(FieldNo("Qty. to Assemble"));
                ATOLink.UpdateAsmFromContratoPlanningLine(Rec);
            end;
        }
        field(901; "Qty. to Assemble (Base)"; Decimal)
        {
            Caption = 'Qty. to Assemble (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Assemble", "Qty. to Assemble (Base)");
            end;
        }
        field(902; "Assemble to Order"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Assemble to Order';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(903; "BOM Item No."; Code[20])
        {
            Caption = 'BOM Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(904; "Attached to Line No."; Integer)
        {
            Caption = 'Attached to Line No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Contrato Planning Line"."Line No." where("Contrato No." = field("Contrato No."),
                                                           "Contrato Task No." = field("Contrato Task No."));
        }
        field(1000; "Contrato Task No."; Code[20])
        {
            Caption = 'contrato Task No.';
            NotBlank = true;
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));
        }
        field(1001; "Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Amount (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Line Amount (LCY)" <> "Line Amount (LCY)", Rec.FieldNo("Line Amount (LCY)"));
                if ("Line Amount (LCY)" <> 0) and (Type = Type::Text) then
                    FieldError(Type);

                InitRoundingPrecisions();
                "Line Amount" := ConvertAmountToFCY("Line Amount (LCY)", AmountRoundingPrecisionFCY);
                UpdateAllAmounts();
            end;
        }
        field(1002; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                ValidateModification(xRec."Unit Cost" <> "Unit Cost", Rec.FieldNo("Unit Cost"));
                if ("Unit Cost" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
                UpdateAllAmounts();
            end;
        }
        field(1003; "Total Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Total Cost';
            Editable = false;
        }
        field(1004; "Unit Price"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';

            trigger OnValidate()
            begin
                ValidateModification(xRec."Unit Price" <> "Unit Price", Rec.FieldNo("Unit Price"));
                if ("Unit Price" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
                UpdateAllAmounts();
            end;
        }
        field(1005; "Total Price"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Total Price';
            Editable = false;
        }
        field(1006; "Line Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';

            trigger OnValidate()
            begin
                ValidateModification(xRec."Line Amount" <> "Line Amount", Rec.FieldNo("Line Amount"));
                if ("Line Amount" <> 0) and (Type = Type::Text) then
                    FieldError(Type);

                UpdateAllAmounts();
            end;
        }
        field(1007; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';

            trigger OnValidate()
            begin
                ValidateModification(xRec."Line Discount Amount" <> "Line Discount Amount", Rec.FieldNo("Line Discount Amount"));
                if ("Line Discount Amount" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
                UpdateAllAmounts();
            end;
        }
        field(1008; "Line Discount Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Discount Amount (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Line Discount Amount (LCY)" <> "Line Discount Amount (LCY)", Rec.FieldNo("Line Discount Amount (LCY)"));
                if ("Line Discount Amount (LCY)" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
                InitRoundingPrecisions();
                "Line Discount Amount" :=
                    ConvertAmountToFCY("Line Discount Amount (LCY)", AmountRoundingPrecisionFCY);
                UpdateAllAmounts();
            end;
        }
        field(1015; "Cost Factor"; Decimal)
        {
            Caption = 'Cost Factor';
            Editable = false;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Cost Factor" <> "Cost Factor", Rec.FieldNo("Cost Factor"));

                UpdateAllAmounts();
            end;
        }
        field(1019; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Editable = false;
        }
        field(1020; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
        }
        field(1021; "Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Line Discount %" <> "Line Discount %", Rec.FieldNo("Line Discount %"));
                if ("Line Discount %" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
                UpdateAllAmounts();
            end;
        }
        field(1022; "Line Type"; Enum "ContratoPlanningLineLineType")
        {
            Caption = 'Line Type';

            trigger OnValidate()
            begin
                "Schedule Line" := true;
                "Contract Line" := true;
                if "Line Type" = "Line Type"::Budget then
                    "Contract Line" := false;
                if "Line Type" = "Line Type"::Billable then
                    "Schedule Line" := false;

                if not "Contract Line" and (("Qty. Transferred to Invoice" <> 0) or ("Qty. Invoiced" <> 0)) then
                    Error(LineTypeErr, TableCaption(), FieldCaption("Line Type"), "Line Type");

                ControlUsageLink();
            end;
        }
        field(1023; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Currency Code" <> "Currency Code", Rec.FieldNo("Currency Code"));

                UpdateCurrencyFactor();
                UpdateAllAmounts();
            end;
        }
        field(1024; "Currency Date"; Date)
        {
            AccessByPermission = TableData Currency = R;
            Caption = 'Currency Date';

            trigger OnValidate()
            begin
                ValidateModification(xRec."Currency Date" <> "Currency Date", Rec.FieldNo("Currency Date"));

                UpdateCurrencyFactor();
                if (CurrFieldNo <> FieldNo("Planning Date")) and (Type <> Type::Text) and ("No." <> '') then
                    UpdateFromCurrency();
            end;
        }
        field(1025; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;

            trigger OnValidate()
            begin
                ValidateModification(xRec."Currency Factor" <> "Currency Factor", Rec.FieldNo("Currency Factor"));

                if ("Currency Code" = '') and ("Currency Factor" <> 0) then
                    FieldError("Currency Factor", StrSubstNo(CurrencyFactorErr, FieldCaption("Currency Code")));
                UpdateAllAmounts();
            end;
        }
        field(1026; "Schedule Line"; Boolean)
        {
            Caption = 'Budget Line';
            Editable = false;
            InitValue = true;
        }
        field(1027; "Contract Line"; Boolean)
        {
            Caption = 'Billable Line';
            Editable = false;
        }
        field(1030; "Contrato Contract Entry No."; Integer)
        {
            Caption = 'contrato Contract Entry No.';
            Editable = false;
        }
        field(1035; "Invoiced Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Contrato Planning Line Invoice"."Invoiced Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                                         "Contrato Task No." = field("Contrato Task No."),
                                                                                         "Contrato Planning Line No." = field("Line No.")));
            Caption = 'Invoiced Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1036; "Invoiced Cost Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Contrato Planning Line Invoice"."Invoiced Cost Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                                              "Contrato Task No." = field("Contrato Task No."),
                                                                                              "Contrato Planning Line No." = field("Line No.")));
            Caption = 'Invoiced Cost Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1037; "VAT Unit Price"; Decimal)
        {
            Caption = 'VAT Unit Price';
        }
        field(1038; "VAT Line Discount Amount"; Decimal)
        {
            Caption = 'VAT Line Discount Amount';
        }
        field(1039; "VAT Line Amount"; Decimal)
        {
            Caption = 'VAT Line Amount';
        }
        field(1041; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(1042; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(1043; "Contrato Ledger Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'contrato Ledger Entry No.';
            Editable = false;
            TableRelation = "Contrato Ledger Entry";
        }
        field(1048; Status; Enum "Contrato Planning Line Status")
        {
            Caption = 'Status';
            Editable = false;
            InitValue = "Order";

            trigger OnValidate()
            begin
                //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo(Status));
            end;
        }
        field(1050; "Ledger Entry Type"; Enum "Contrato Ledger Entry Type")
        {
            Caption = 'Ledger Entry Type';
        }
        field(1051; "Ledger Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Ledger Entry No.';
            TableRelation = if ("Ledger Entry Type" = const(Resource)) "Res. Ledger Entry"
            else
            if ("Ledger Entry Type" = const(Item)) "Item Ledger Entry"
            else
            if ("Ledger Entry Type" = const("G/L Account")) "G/L Entry";
        }
        field(1052; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
        }
        field(1053; "Usage Link"; Boolean)
        {
            Caption = 'Usage Link';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateUsageLink(Rec, xRec, IsHandled);
                if not IsHandled then
                    if "Usage Link" and ("Line Type" = "Line Type"::Billable) then
                        Error(UsageLinkErr, FieldCaption("Usage Link"), TableCaption(), FieldCaption("Line Type"), "Line Type");

                ControlUsageLink();

                CheckItemAvailable(FieldNo("Usage Link"));
                UpdateReservation(FieldNo("Usage Link"));
            end;
        }
        field(1060; "Remaining Qty."; Decimal)
        {
            Caption = 'Remaining Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                Validate("Remaining Qty. (Base)", CalcBaseQty("Remaining Qty.", FieldCaption("Remaining Qty."), FieldCaption("Remaining Qty. (Base)")));
            end;
        }
        field(1061; "Remaining Qty. (Base)"; Decimal)
        {
            Caption = 'Remaining Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(1062; "Remaining Total Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Remaining Total Cost';
            Editable = false;
        }
        field(1063; "Remaining Total Cost (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Total Cost (LCY)';
            Editable = false;
        }
        field(1064; "Remaining Line Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Remaining Line Amount';
            Editable = false;
        }
        field(1065; "Remaining Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Line Amount (LCY)';
            Editable = false;
        }
        field(1070; "Qty. Posted"; Decimal)
        {
            Caption = 'Qty. Posted';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(1071; "Qty. to Transfer to Journal"; Decimal)
        {
            Caption = 'Qty. to Transfer to Journal';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if ("Qty. to Transfer to Journal" <> 0) and (Type = Type::Text) then
                    FieldError(Type);
            end;
        }
        field(1072; "Posted Total Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Posted Total Cost';
            Editable = false;
        }
        field(1073; "Posted Total Cost (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Posted Total Cost (LCY)';
            Editable = false;
        }
        field(1074; "Posted Line Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Posted Line Amount';
            Editable = false;
        }
        field(1075; "Posted Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Posted Line Amount (LCY)';
            Editable = false;
        }
        field(1080; "Qty. Transferred to Invoice"; Decimal)
        {
            CalcFormula = sum("Contrato Planning Line Invoice"."Quantity Transferred" where("Contrato No." = field("Contrato No."),
                                                                                        "Contrato Task No." = field("Contrato Task No."),
                                                                                        "Contrato Planning Line No." = field("Line No.")));
            Caption = 'Qty. Transferred to Invoice';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1081; "Qty. to Transfer to Invoice"; Decimal)
        {
            Caption = 'Qty. to Transfer to Invoice';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyToTransferToInvoice(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if "Qty. to Transfer to Invoice" = 0 then
                    exit;

                if Type = Type::Text then
                    FieldError(Type);

                if "Contract Line" then begin
                    if Quantity = "Qty. Transferred to Invoice" then
                        Error(QtyAlreadyTransferredErr, TableCaption);

                    if Quantity > 0 then begin
                        if ("Qty. to Transfer to Invoice" > 0) and ("Qty. to Transfer to Invoice" > (Quantity - "Qty. Transferred to Invoice")) or
                           ("Qty. to Transfer to Invoice" < 0)
                        then
                            Error(QtyToTransferToInvoiceErr, FieldCaption("Qty. to Transfer to Invoice"), 0, Quantity - "Qty. Transferred to Invoice");
                    end else
                        if ("Qty. to Transfer to Invoice" > 0) or
                           ("Qty. to Transfer to Invoice" < 0) and ("Qty. to Transfer to Invoice" < (Quantity - "Qty. Transferred to Invoice"))
                        then
                            Error(QtyToTransferToInvoiceErr, FieldCaption("Qty. to Transfer to Invoice"), Quantity - "Qty. Transferred to Invoice", 0);
                end else
                    Error(NoContractLineErr, FieldCaption("Qty. to Transfer to Invoice"), TableCaption(), "Line Type");
            end;
        }
        field(1090; "Qty. Invoiced"; Decimal)
        {
            CalcFormula = sum("Contrato Planning Line Invoice"."Quantity Transferred" where("Contrato No." = field("Contrato No."),
                                                                                        "Contrato Task No." = field("Contrato Task No."),
                                                                                        "Contrato Planning Line No." = field("Line No."),
                                                                                        "Document Type" = filter("Posted Invoice" | "Posted Credit Memo")));
            Caption = 'Qty. Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1091; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(1100; "Reserved Quantity"; Decimal)
        {
            AccessByPermission = TableData Item = R;
            CalcFormula = - sum("Reservation Entry".Quantity where("Source Type" = const(1003),
#pragma warning disable AL0603
                                                                   "Source Subtype" = field(Status),
#pragma warning restore
                                                                   "Source ID" = field("Contrato No."),
                                                                   "Source Ref. No." = field("Contrato Contract Entry No."),
                                                                   "Reservation Status" = const(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1101; "Reserved Qty. (Base)"; Decimal)
        {
            AccessByPermission = TableData Item = R;
            CalcFormula = - sum("Reservation Entry"."Quantity (Base)" where("Source Type" = const(1003),
#pragma warning disable AL0603
                                                                            "Source Subtype" = field(Status),
#pragma warning restore
                                                                            "Source ID" = field("Contrato No."),
                                                                            "Source Ref. No." = field("Contrato Contract Entry No."),
                                                                            "Reservation Status" = const(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure");
                UpdatePlanned();
            end;
        }
        field(1102; Reserve; Enum "Reserve Method")
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Reserve';

            trigger OnValidate()
            begin
                if Reserve <> Reserve::Never then begin
                    TestField(Type, Type::Item);
                    TestField("No.");
                    TestField("Usage Link");
                end;
                CalcFields("Reserved Qty. (Base)");
                if (Reserve = Reserve::Never) and ("Reserved Qty. (Base)" > 0) then
                    TestField("Reserved Qty. (Base)", 0);

                if xRec.Reserve = Reserve::Always then begin
                    GetItem();
                    if Item.Reserve = Item.Reserve::Always then
                        TestField(Reserve, Reserve::Always);
                end;
            end;
        }
        field(1103; Planned; Boolean)
        {
            Caption = 'Planned';
            Editable = false;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."), Blocked = const(false));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                ValidateModification(xRec."Variant Code" <> "Variant Code", Rec.FieldNo("Variant Code"));

                if Rec."Variant Code" = '' then begin
                    if Type = Type::Item then begin
                        Item.Get("No.");
                        Description := Item.Description;
                        "Description 2" := Item."Description 2";
                    end
                end else begin
                    TestField(Type, Type::Item);
                    ItemVariant.SetLoadFields(Description, "Description 2", Blocked);
                    ItemVariant.Get("No.", "Variant Code");
                    ItemVariant.TestField(Blocked, false);
                    Description := ItemVariant.Description;
                    "Description 2" := ItemVariant."Description 2";
                end;
                GetItemTranslation();
                Validate(Quantity);
                CheckItemAvailable(FieldNo("Variant Code"));
                UpdateReservation(FieldNo("Variant Code"));
                InitQtyToAsm();
                //ATOLink.UpdateAsmFromContratoPlanningLine(Rec);
                //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo("Variant Code"));
            end;
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));

            trigger OnValidate()
            var
                WMSManagement: Codeunit "WMS Management";
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
                BinCodeCaption: Text[30];
            begin
                ValidateModification(xRec."Bin Code" <> "Bin Code", Rec.FieldNo("Bin Code"));
                if "Bin Code" <> '' then begin
                    TestField("Location Code");
                    GetLocation("Location Code");
                    TestField(Type, Type::Item);
                    GetItem();
                    Item.TestField(Type, Item.Type::Inventory);
                    CheckItemAvailable(FieldNo("Bin Code"));
                    WMSManagement.FindBin("Location Code", "Bin Code", '');
                    BinCodeCaption := CopyStr(FieldCaption("Bin Code"), 1, 30);
                    WhseIntegrationMgt.CheckBinTypeAndCode(
                        DATABASE::"Contrato Planning Line", BinCodeCaption, "Location Code", "Bin Code", 0);
                    CheckBin();
                end;

                UpdateReservation(FieldNo("Bin Code"));
                //ContratoWarehouseMgt.ContratoPlanningLineVerifyChange(Rec, xRec, FieldNo("Bin Code"));
                // ATOLink.UpdateAsmBinCodeFromContratoPlanningLine(Rec);
            end;

            trigger OnLookup()
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                TestField("Location Code");
                TestField(Type, Type::Item);

                if Item.Get(Rec."No.") then
                    if BinCode <> '' then
                        Item.TestField(Type, Item.Type::Inventory);

                if Quantity > 0 then
                    BinCode := WMSManagement.BinContentLookUp("Location Code", "No.", "Variant Code", '', "Bin Code")
                else
                    BinCode := WMSManagement.BinLookUp("Location Code", "No.", "Variant Code", '');

                if BinCode <> '' then
                    Validate("Bin Code", BinCode);
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5410; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQuantityBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(5790; "Requested Delivery Date"; Date)
        {
            Caption = 'Requested Delivery Date';

            trigger OnValidate()
            begin
                if ("Requested Delivery Date" <> xRec."Requested Delivery Date") and
                   ("Promised Delivery Date" <> 0D)
                then
                    Error(
                      RequestedDeliveryDateErr,
                      FieldCaption("Requested Delivery Date"),
                      FieldCaption("Promised Delivery Date"));

                if "Requested Delivery Date" <> 0D then
                    Validate("Planned Delivery Date", "Requested Delivery Date")
            end;
        }
        field(5791; "Promised Delivery Date"; Date)
        {
            Caption = 'Promised Delivery Date';

            trigger OnValidate()
            begin
                if "Promised Delivery Date" <> 0D then
                    Validate("Planned Delivery Date", "Promised Delivery Date")
                else
                    Validate("Requested Delivery Date");
            end;
        }
        field(5794; "Planned Delivery Date"; Date)
        {
            Caption = 'Planned Delivery Date';

            trigger OnValidate()
            begin
                Validate("Planning Date", "Planned Delivery Date");
            end;
        }
        field(5900; "Service Order No."; Code[20])
        {
            Caption = 'Service Order No.';
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
            Editable = false;
        }
        field(7000; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
        }
        field(7001; "Cost Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Cost Calculation Method';
        }
        field(7300; "Pick Qty."; Decimal)
        {
            CalcFormula = sum("Warehouse Activity Line"."Qty. Outstanding" where("Activity Type" = filter(<> "Put-away"),
                                                                                  "Source Type" = const(167),
                                                                                  "Source No." = field("Contrato No."),
                                                                                  "Source Line No." = field("Contrato Contract Entry No."),
                                                                                  "Source Subline No." = field("Line No."),
                                                                                  "Unit of Measure Code" = field("Unit of Measure Code"),
                                                                                  "Action Type" = filter(" " | Place),
                                                                                  "Original Breakbulk" = const(false),
                                                                                  "Breakbulk No." = const(0)));
            Caption = 'Pick Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(7301; "Qty. Picked"; Decimal)
        {
            Caption = 'Qty. Picked';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Picked (Base)" :=
                    UOMMgt.CalcBaseQty("No.", "Variant Code", "Unit of Measure Code", "Qty. Picked", "Qty. per Unit of Measure");

                "Completely Picked" := "Qty. Picked" >= Quantity;
            end;
        }
        field(7302; "Qty. Picked (Base)"; Decimal)
        {
            Caption = 'Qty. Picked (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(7303; "Completely Picked"; Boolean)
        {
            Caption = 'Completely Picked';
            Editable = false;
        }
        field(7304; "Pick Qty. (Base)"; Decimal)
        {
            CalcFormula = sum("Warehouse Activity Line"."Qty. Outstanding (Base)" where("Activity Type" = filter(<> "Put-away"),
                                                                                         "Source Type" = const(167),
                                                                                         "Source No." = field("Contrato No."),
                                                                                         "Source Line No." = field("Contrato Contract Entry No."),
                                                                                         "Source Subline No." = field("Line No."),
                                                                                         "Action Type" = filter(" " | Place),
                                                                                         "Original Breakbulk" = const(false),
                                                                                         "Breakbulk No." = const(0)));
            Caption = 'Pick Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(7305; "Qty. on Journal"; Decimal)
        {
            CalcFormula = sum("Contrato Journal Line"."Quantity (Base)" where("Contrato No." = field("Contrato No."),
                                                                  "Contrato Task No." = field("Contrato Task No."),
                                                                  "Contrato Planning Line No." = field("Line No."),
                                                                  Type = field(Type),
                                                                  "No." = field("No.")));
            Caption = 'Qty. on Journal';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Contrato No.", "Contrato Task No.", "Schedule Line", "Planning Date")
        {
            SumIndexFields = "Total Price (LCY)", "Total Cost (LCY)", "Line Amount (LCY)", "Remaining Total Cost (LCY)", "Remaining Line Amount (LCY)", "Total Cost", "Line Amount";
        }
        key(Key3; "Contrato No.", "Contrato Task No.", "Contract Line", "Planning Date")
        {
            SumIndexFields = "Total Price (LCY)", "Total Cost (LCY)", "Line Amount (LCY)", "Remaining Total Cost (LCY)", "Remaining Line Amount (LCY)", "Total Cost", "Line Amount";
        }
        key(Key4; "Contrato No.", "Contrato Task No.", "Schedule Line", "Currency Date")
        {
        }
        key(Key5; "Contrato No.", "Contrato Task No.", "Contract Line", "Currency Date")
        {
        }
        key(Key6; "Contrato No.", "Schedule Line", Type, "No.", "Planning Date")
        {
            SumIndexFields = "Quantity (Base)";
        }
        key(Key7; "Contrato No.", "Schedule Line", Type, "Resource Group No.", "Planning Date")
        {
            SumIndexFields = "Quantity (Base)";
        }
        key(Key8; Status, "Schedule Line", Type, "No.", "Planning Date")
        {
            SumIndexFields = "Quantity (Base)";
        }
        key(Key9; Status, "Schedule Line", Type, "Resource Group No.", "Planning Date")
        {
            SumIndexFields = "Quantity (Base)";
        }
        key(Key10; "Contrato No.", "Contract Line")
        {
        }
        key(Key11; "Contrato Contract Entry No.")
        {
        }
        key(Key12; Type, "No.", "Contrato No.", "Contrato Task No.", "Usage Link", "System-Created Entry")
        {
        }
        key(Key13; Status, Type, "No.", "Variant Code", "Location Code", "Planning Date")
        {
            SumIndexFields = "Remaining Qty. (Base)";
        }
        key(Key14; "Contrato No.", "Planning Date", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ContratoUsageLink: Record "Contrato Usage Link";
        IsHandled: Boolean;
    begin
        ConfirmDeletion();

        ValidateModification(true, 0);
        CheckRelatedContratoPlanningLineInvoice();

        if "Usage Link" then begin
            ContratoUsageLink.SetRange("Contrato No.", "Contrato No.");
            ContratoUsageLink.SetRange("Contrato Task No.", "Contrato Task No.");
            ContratoUsageLink.SetRange("Line No.", "Line No.");
            IsHandled := false;
            OnDeleteOnAfterSetFilterOnContratoUsageLink(Rec, ContratoUsageLink, IsHandled);
            if not IsHandled then
                if not ContratoUsageLink.IsEmpty() then
                    Error(ContratoUsageLinkErr, TableCaption);
        end;

        if (Rec.Quantity <> 0) and ItemExists(Rec."No.") then begin
            //ContratoPlanningLineReserve.DeleteLine(Rec);
            CalcFields("Reserved Qty. (Base)");
            TestField("Reserved Qty. (Base)", 0);
        end;

        if "Schedule Line" then
            Contrato.UpdateOverBudgetValue("Contrato No.", false, "Total Cost (LCY)");

        //ContratoWarehouseMgt.ContratoPlanningLineDelete(Rec);

        // if Rec.Type = Rec.Type::Item then
        //     ATOLink.DeleteAsmFromContratoPlanningLine(Rec);

        DeleteWarehouseRequest(Rec);
    end;

    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        LockTable();
        GetContrato();
        if Contrato.Blocked = Contrato.Blocked::All then
            Contrato.TestBlocked();
        ContratoTask.Get("Contrato No.", "Contrato Task No.");
        ContratoTask.TestField("Contrato Task Type", ContratoTask."Contrato Task Type"::Posting);
        InitContratoPlanningLine();
        if Quantity <> 0 then
            UpdateReservation(0);

        if "Schedule Line" then
            Contrato.UpdateOverBudgetValue("Contrato No.", false, "Total Cost (LCY)");

        CreateWarehouseRequest();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));

        if ((Quantity <> 0) or (xRec.Quantity <> 0)) and ItemExists(xRec."No.") then
            UpdateReservation(0);

        if "Schedule Line" then
            Contrato.UpdateOverBudgetValue("Contrato No.", false, "Total Cost (LCY)");

        if xRec."Location Code" <> Rec."Location Code" then begin
            DeleteWarehouseRequest(xRec);
            CreateWarehouseRequest();
        end;
    end;

    trigger OnRename()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnRename(Rec, IsHandled);
        if IsHandled then
            exit;

        Error(RecordRenameErr, FieldCaption("Contrato No."), FieldCaption("Contrato Task No."), TableCaption);
    end;

    var
        GLAcc: Record "G/L Account";
        Location: Record Location;
        Item: Record Item;
        ContratoTask: Record "Contrato Task";
        Res: Record Resource;
        WorkType: Record "Work Type";
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        CurrExchRate: Record "Currency Exchange Rate";
        SKU: Record "Stockkeeping Unit";
        StandardText: Record "Standard Text";
        ItemTranslation: Record "Item Translation";
        GLSetup: Record "General Ledger Setup";
        ATOLink: Record "Assemble-to-OrderLinkContrato";
        ContratoPlanningLineReserve: Codeunit "Contrato Planning Line-Reserve";
        ContratoWarehouseMgt: Codeunit "ContratoWhseValidateSourceLine";
        UOMMgt: Codeunit "Unit of Measure Management";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        CurrencyFactorErr: Label 'cannot be specified without %1', Comment = '%1 = Currency Code field name';
        RecordRenameErr: Label 'You cannot change the %1 or %2 of this %3.', Comment = '%1 = contrato Number field name; %2 = contrato Task Number field name; %3 = contrato Planning Line table name';
        CurrencyDate: Date;
        MissingItemResourceGLErr: Label 'You must specify %1 %2 in planning line.', Comment = '%1 = Document Type (Item, Resoure, or G/L); %2 = Field name';
        HasGotGLSetup: Boolean;
        QtyLessErr: Label '%1 cannot be less than %2.', Comment = '%1 = Name of first field to compare; %2 = Name of second field to compare';
        ControlUsageLinkErr: Label 'The %1 must be a %2 and %3 must be enabled, because linked contrato Ledger Entries exist.', Comment = '%1 = contrato Planning Line table name; %2 = Caption for field Schedule Line; %3 = Captiion for field Usage Link';
        ContratoUsageLinkErr: Label 'This %1 cannot be deleted because linked contrato ledger entries exist.', Comment = '%1 = contrato Planning Line table name';
        BypassQtyValidation: Boolean;
        SkipCheckForMultipleContratosOnSalesLine: Boolean;
        CalledFromHeader: Boolean;
        LinkedContratoLedgerErr: Label 'You cannot change this value because linked contrato ledger entries exist.';
        LineTypeErr: Label 'The %1 cannot be of %2 %3 because it is transferred to an invoice.', Comment = 'The contrato Planning Line cannot be of Line Type Schedule, because it is transferred to an invoice.';
        QtyToTransferToInvoiceErr: Label '%1 may not be lower than %2 and may not exceed %3.', Comment = '%1 = Qty. to Transfer to Invoice field name; %2 = First value in comparison; %3 = Second value in comparison';
        AutoReserveQst: Label 'Automatic reservation is not possible.\Do you want to reserve items manually?';
        NoContractLineErr: Label '%1 cannot be set on a %2 of type %3.', Comment = '%1 = Qty. to Transfer to Invoice field name; %2 = contrato Planning Line table name; %3 = The contrato''s line type';
        QtyAlreadyTransferredErr: Label 'The %1 has already been completely transferred.', Comment = '%1 = contrato Planning Line table name';
        UsageLinkErr: Label '%1 cannot be enabled on a %2 with %3 %4.', Comment = 'Usage Link cannot be enabled on a contrato Planning Line with Line Type Schedule';
        QtyGreaterErr: Label '%1 cannot be higher than %2.', Comment = '%1 = Caption for field Quantity; %2 = Captiion for field Qty. Transferred to Invoice';
        RequestedDeliveryDateErr: Label 'You cannot change the %1 when the %2 has been filled in.', Comment = '%1 = Caption for field Requested Delivery Date; %2 = Captiion for field Promised Delivery Date';
        NotPossibleContratoPlanningLineErr: Label 'It is not possible to deleted contrato planning line transferred to an invoice.';
        NegativeQtyToAssembleErr: Label ' must be positive.', Comment = 'Qty. to Assemble can''t be negative';
        DifferentQtyToAssembleErr: Label ' must be equal to %1.', Comment = 'Qty. to Assemble must be equal to Quantity, %1 = Quantity';
        CannotBeMoreErr: Label 'cannot be more than %1', Comment = '%1 = Quantity';
        ConfirmDeleteQst: Label '%1 = %2 is greater than %3 = %4. If you delete the %5, the items will remain in the operation area until you put them away.\Related Item Tracking information defined during pick will be deleted.\Do you still want to delete the %5?', Comment = '%1 = FieldCaption("Qty. Picked"), %2 = "Qty. Picked", %3 = FieldCaption("Qty. Posted"), %4 = "Qty. Posted", %5 = TableCaption';

    protected var
        Contrato: Record Contrato;
        UnitAmountRoundingPrecision: Decimal;
        AmountRoundingPrecision: Decimal;
        UnitAmountRoundingPrecisionFCY: Decimal;
        AmountRoundingPrecisionFCY: Decimal;

    internal procedure OpenItemTrackingLines()
    begin
        //ContratoPlanningLineReserve.CallItemTracking(Rec);
    end;

    internal procedure IsInbound(): Boolean
    begin
        exit("Quantity (Base)" < 0);
    end;

    procedure CheckItemAvailable(CalledByFieldNo: Integer)
    begin
        if CurrFieldNo <> CalledByFieldNo then
            exit;
        if (Type <> Type::Item) or ("No." = '') then
            exit;
        if Quantity <= 0 then
            exit;
        if not (Status in [Status::Order]) then
            exit;

        // if ItemCheckAvail.ContratoPlanningLineCheck(Rec) then
        //     ItemCheckAvail.RaiseUpdateInterruptedError();
    end;

    local procedure CheckBin()
    var
        BinContent: Record "Bin Content";
        Bin: Record Bin;
    begin
        if "Bin Code" <> '' then begin
            GetLocation("Location Code");
            if not Location."Check Whse. Class" then
                exit;

            if BinContent.Get(
                 "Location Code", "Bin Code",
                 "No.", "Variant Code", "Unit of Measure Code")
            then begin
                if not BinContent.CheckWhseClass(false) then
                    "Bin Code" := '';
            end else begin
                Bin.Get("Location Code", "Bin Code");
                if not Bin.CheckWhseClass("No.", false) then
                    "Bin Code" := '';
            end;
        end;
    end;

    local procedure CopyFieldsFromContrato()
    begin
        GetContrato();
        Rec."Customer Price Group" := Contrato."Customer Price Group";
        Rec."Price Calculation Method" := Contrato.GetPriceCalculationMethod();
        Rec."Cost Calculation Method" := Contrato.GetCostCalculationMethod();

        OnAfterCopyFieldsFromContrato(Rec, xRec, Contrato);
    end;

    local procedure CheckQuantityPosted()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckQuantityPosted(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "Usage Link" then
            if not BypassQtyValidation then begin
                if ("Qty. Posted" > 0) and (Quantity < "Qty. Posted") then
                    Error(QtyLessErr, FieldCaption(Quantity), FieldCaption("Qty. Posted"));
                if ("Qty. Posted" < 0) and (Quantity > "Qty. Posted") then
                    Error(QtyGreaterErr, FieldCaption(Quantity), FieldCaption("Qty. Posted"));
            end;
    end;

    local procedure CopyFromResource()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyFromResource(Rec, xRec, IsHandled);
        if not IsHandled then begin
            Res.Get("No.");
            Res.CheckResourcePrivacyBlocked(false);
            Res.TestField(Blocked, false);
            Res.TestField("Gen. Prod. Posting Group");
            if Description = '' then
                Description := Res.Name;
            if "Description 2" = '' then
                "Description 2" := Res."Name 2";
            "Gen. Prod. Posting Group" := Res."Gen. Prod. Posting Group";
            "Resource Group No." := Res."Resource Group No.";
            Validate("Unit of Measure Code", Res."Base Unit of Measure");
        end;
        OnAfterCopyFromResource(Rec, Contrato, Res);
    end;

    local procedure CopyFromItem()
    begin
        GetItem();
        Item.TestField(Blocked, false);
        Item.TestField("Gen. Prod. Posting Group");
        Description := Item.Description;
        "Description 2" := Item."Description 2";
        if Contrato."Language Code" <> '' then
            GetItemTranslation();
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        Validate("Unit of Measure Code", Item."Base Unit of Measure");
        if "Usage Link" then
            if Item.Reserve = Item.Reserve::Optional then
                Reserve := Contrato.Reserve
            else
                Reserve := Item.Reserve;
        OnAfterCopyFromItem(Rec, Contrato, Item);
    end;

    local procedure CopyFromGLAccount()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyFromGLAccount(Rec, IsHandled, Contrato);
        if not IsHandled then begin
            GLAcc.Get("No.");
            GLAcc.CheckGLAcc();
            GLAcc.TestField("Direct Posting", true);
            GLAcc.TestField("Gen. Prod. Posting Group");
            Description := GLAcc.Name;
            "Gen. Bus. Posting Group" := GLAcc."Gen. Bus. Posting Group";
            "Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
            "Unit of Measure Code" := '';
            "Direct Unit Cost (LCY)" := 0;
            "Unit Cost (LCY)" := 0;
            "Unit Price" := 0;
        end;

        OnAfterCopyFromGLAccount(Rec, Contrato, GLAcc);
    end;

    local procedure CopyFromStandardText()
    begin
        StandardText.Get("No.");
        Description := StandardText.Description;
    end;

    local procedure CalcQuantityBase()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcQuantityBase(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure EnsureDirectedPutawayandPickFalse(var LocationToCheck: Record Location)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeEnsureDirectedPutawayandPickFalse(Rec, LocationToCheck, IsHandled);
        if IsHandled then
            exit;

        LocationToCheck.TestField("Directed Put-away and Pick", false);
    end;

    procedure GetContrato()
    begin
        if ("Contrato No." <> Contrato."No.") and ("Contrato No." <> '') then
            Contrato.Get("Contrato No.");
        OnAfterGetContrato(Rec, Contrato);
    end;

    procedure UpdateCurrencyFactor()
    begin
        if "Currency Code" <> '' then begin
            if "Currency Date" = 0D then
                CurrencyDate := WorkDate()
            else
                CurrencyDate := "Currency Date";
            OnUpdateCurrencyFactorOnBeforeGetExchangeRate(Rec, CurrExchRate);
            "Currency Factor" := CurrExchRate.ExchangeRate(CurrencyDate, "Currency Code");
        end else
            "Currency Factor" := 0;
        OnAfterUpdateCurrencyFactor(Rec);
    end;

    local procedure ItemExists(ItemNo: Code[20]): Boolean
    var
        Item2: Record Item;
    begin
        if Type = Type::Item then
            if not Item2.Get(ItemNo) then
                exit(false);
        exit(true);
    end;

    local procedure GetItem()
    begin
        if "No." <> Item."No." then
            if not Item.Get("No.") then
                Clear(Item);
    end;

    local procedure GetSKU() Result: Boolean
    begin
        if (SKU."Location Code" = "Location Code") and
           (SKU."Item No." = "No.") and
           (SKU."Variant Code" = "Variant Code")
        then
            exit(true);

        if SKU.Get("Location Code", "No.", "Variant Code") then
            exit(true);

        Result := false;
        OnAfterGetSKU(Rec, Result);
    end;

    procedure InitRoundingPrecisions()
    var
        Currency: Record Currency;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitRoundingPrecisions(Rec, AmountRoundingPrecision, UnitAmountRoundingPrecision, AmountRoundingPrecisionFCY, UnitAmountRoundingPrecisionFCY, IsHandled);
        if IsHandled then
            exit;

        if (AmountRoundingPrecision = 0) or
           (UnitAmountRoundingPrecision = 0) or
           (AmountRoundingPrecisionFCY = 0) or
           (UnitAmountRoundingPrecisionFCY = 0)
        then begin
            Clear(Currency);
            Currency.InitRoundingPrecision();
            AmountRoundingPrecision := Currency."Amount Rounding Precision";
            UnitAmountRoundingPrecision := Currency."Unit-Amount Rounding Precision";

            if "Currency Code" <> '' then begin
                Currency.Get("Currency Code");
                Currency.TestField("Amount Rounding Precision");
                Currency.TestField("Unit-Amount Rounding Precision");
            end;

            AmountRoundingPrecisionFCY := Currency."Amount Rounding Precision";
            UnitAmountRoundingPrecisionFCY := Currency."Unit-Amount Rounding Precision";
        end;
    end;

    procedure Caption(): Text
    var
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        Result: Text;
        IsHandled: Boolean;
    begin
        Result := '';
        IsHandled := false;
        OnBeforeCaption(Rec, IsHandled, Result);
        if IsHandled then
            exit(Result);

        if not Contrato.Get("Contrato No.") then
            exit('');
        if not ContratoTask.Get("Contrato No.", "Contrato Task No.") then
            exit('');
        exit(StrSubstNo('%1 %2 %3 %4',
            Contrato."No.",
            Contrato.Description,
            ContratoTask."Contrato Task No.",
            ContratoTask.Description));
    end;

    procedure SetUpNewLine(LastContratoPlanningLine: Record "Contrato Planning Line")
    begin
        "Document Date" := LastContratoPlanningLine."Planning Date";
        "Document No." := LastContratoPlanningLine."Document No.";
        Type := LastContratoPlanningLine.Type;
        Validate("Line Type", LastContratoPlanningLine."Line Type");
        GetContrato();
        "Currency Code" := Contrato."Currency Code";
        UpdateCurrencyFactor();
        if LastContratoPlanningLine."Planning Date" <> 0D then
            Validate("Planning Date", LastContratoPlanningLine."Planning Date");
        "Price Calculation Method" := Contrato.GetPriceCalculationMethod();
        "Cost Calculation Method" := Contrato.GetCostCalculationMethod();

        OnAfterSetupNewLine(Rec, LastContratoPlanningLine);
    end;

    procedure InitContratoPlanningLine()
    var
        ContratoJnlManagement: Codeunit ContratoJnlManagement;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitContratoPlanningLine(Rec, Contrato, IsHandled);
        if not IsHandled then begin
            GetContrato();
            if "Planning Date" = 0D then
                Validate("Planning Date", WorkDate());
            "Currency Code" := Contrato."Currency Code";
            UpdateCurrencyFactor();
            "VAT Unit Price" := 0;
            "VAT Line Discount Amount" := 0;
            "VAT Line Amount" := 0;
            "VAT %" := 0;
            "Contrato Contract Entry No." := ContratoJnlManagement.GetNextEntryNo();
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            "Last Date Modified" := 0D;
            Status := Contrato.Status;
            ControlUsageLink();
            "Country/Region Code" := Contrato."Bill-to Country/Region Code";
        end;
        OnAfterInitContratoPlanningLine(Rec);
    end;

    local procedure DeleteAmounts()
    begin
        Quantity := 0;
        "Quantity (Base)" := 0;

        "Direct Unit Cost (LCY)" := 0;
        "Unit Cost (LCY)" := 0;
        "Unit Cost" := 0;

        "Total Cost (LCY)" := 0;
        "Total Cost" := 0;

        "Unit Price (LCY)" := 0;
        "Unit Price" := 0;

        "Total Price (LCY)" := 0;
        "Total Price" := 0;

        "Line Amount (LCY)" := 0;
        "Line Amount" := 0;

        "Line Discount %" := 0;

        "Line Discount Amount (LCY)" := 0;
        "Line Discount Amount" := 0;

        "Remaining Qty." := 0;
        "Remaining Qty. (Base)" := 0;
        "Remaining Total Cost" := 0;
        "Remaining Total Cost (LCY)" := 0;
        "Remaining Line Amount" := 0;
        "Remaining Line Amount (LCY)" := 0;

        "Qty. Posted" := 0;
        "Qty. to Transfer to Journal" := 0;
        "Posted Total Cost" := 0;
        "Posted Total Cost (LCY)" := 0;
        "Posted Line Amount" := 0;
        "Posted Line Amount (LCY)" := 0;

        "Qty. to Transfer to Invoice" := 0;
        "Qty. to Invoice" := 0;

        OnAfterDeleteAmounts(Rec);
    end;

    local procedure UpdateFromCurrency()
    begin
        UpdateAllAmounts();
    end;

    local procedure GetItemTranslation()
    begin
        GetContrato();
        if ItemTranslation.Get("No.", "Variant Code", Contrato."Language Code") then begin
            Description := ItemTranslation.Description;
            "Description 2" := ItemTranslation."Description 2";
        end;
    end;

    local procedure GetGLSetup()
    begin
        if HasGotGLSetup then
            exit;
        GLSetup.Get();
        HasGotGLSetup := true;
    end;

    procedure GetRemainingQty(var RemainingQty: Decimal; var RemainingQtyBase: Decimal)
    begin
        CalcFields("Reserved Quantity", "Reserved Qty. (Base)");
        RemainingQty := "Remaining Qty." - Abs("Reserved Quantity");
        RemainingQtyBase := "Remaining Qty. (Base)" - Abs("Reserved Qty. (Base)");
        OnAfterGetRemainingQty(Rec, RemainingQty, RemainingQtyBase);
    end;

    procedure GetReservationQty(var QtyReserved: Decimal; var QtyReservedBase: Decimal; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal): Decimal
    begin
        CalcFields("Reserved Quantity", "Reserved Qty. (Base)");
        QtyReserved := "Reserved Quantity";
        QtyReservedBase := "Reserved Qty. (Base)";
        QtyToReserve := "Remaining Qty.";
        QtyToReserveBase := "Remaining Qty. (Base)";
        exit("Qty. per Unit of Measure");
    end;

    procedure GetSourceCaption(): Text
    begin
        exit(StrSubstNo('%1 %2 %3', Status, "Contrato No.", "No."));
    end;

    procedure SetReservationEntry(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSource(DATABASE::"Contrato Planning Line", Status.AsInteger(), "Contrato No.", "Contrato Contract Entry No.", '', 0);
        ReservEntry.SetItemData("No.", Description, "Location Code", "Variant Code", "Qty. per Unit of Measure");
        if Type <> Type::Item then
            ReservEntry."Item No." := '';
        ReservEntry."Expected Receipt Date" := "Planning Date";
        ReservEntry."Shipment Date" := "Planning Date";
    end;

    procedure SetReservationFilters(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSourceFilter(DATABASE::"Contrato Planning Line", Status.AsInteger(), "Contrato No.", "Contrato Contract Entry No.", false);
        ReservEntry.SetSourceFilter('', 0);

        OnAfterSetReservationFilters(ReservEntry, Rec);
    end;

    procedure ReservEntryExist(): Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.InitSortingAndFilters(false);
        SetReservationFilters(ReservEntry);
        exit(not ReservEntry.IsEmpty);
    end;

    procedure UpdateAllAmounts()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateAllAmounts(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        InitRoundingPrecisions();

        UpdateUnitCost();
        FindPriceAndDiscount(CurrFieldNo);
        UpdateTotalCost();
        HandleCostFactor();
        UpdateUnitPrice();
        UpdateTotalPrice();
        UpdateAmountsAndDiscounts();
        UpdateRemainingCostsAndAmounts("Currency Date", "Currency Factor");

        OnAfterUpdateAllAmounts(Rec, xRec);
    end;

    local procedure UpdateUnitCost()
    var
        RetrievedCost: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateUnitCost(Rec, IsHandled, xRec);
        if IsHandled then
            exit;

        GetContrato();
        if (Type = Type::Item) and Item.Get("No.") then
            if Item."Costing Method" = Item."Costing Method"::Standard then
                if RetrieveCostPrice(CurrFieldNo) then begin
                    if GetSKU() then
                        "Unit Cost (LCY)" := Round(SKU."Unit Cost" * "Qty. per Unit of Measure", UnitAmountRoundingPrecision)
                    else
                        "Unit Cost (LCY)" := Round(Item."Unit Cost" * "Qty. per Unit of Measure", UnitAmountRoundingPrecision);
                    "Unit Cost" := ConvertAmountToFCY("Unit Cost (LCY)", UnitAmountRoundingPrecisionFCY);
                end else
                    RecalculateAmounts(Contrato."Exch. Calculation (Cost)", xRec."Unit Cost", "Unit Cost", "Unit Cost (LCY)")
            else
                if RetrieveCostPrice(CurrFieldNo) then begin
                    CalculateRetrievedCost(RetrievedCost);
                    "Unit Cost" := ConvertAmountToFCY(RetrievedCost, UnitAmountRoundingPrecisionFCY);
                    "Unit Cost (LCY)" := Round(RetrievedCost, UnitAmountRoundingPrecision);
                end else
                    RecalculateAmounts(Contrato."Exch. Calculation (Cost)", xRec."Unit Cost", "Unit Cost", "Unit Cost (LCY)")
        else
            RecalculateAmounts(Contrato."Exch. Calculation (Cost)", xRec."Unit Cost", "Unit Cost", "Unit Cost (LCY)");
    end;

    local procedure CalculateRetrievedCost(var RetrievedCost: Decimal)
    begin
        if GetSKU() then
            RetrievedCost := SKU."Unit Cost" * Rec."Qty. per Unit of Measure"
        else
            RetrievedCost := Item."Unit Cost" * Rec."Qty. per Unit of Measure";
        OnAfterCalculateRetrievedCost(Rec, xRec, SKU, Item, RetrievedCost);
    end;

#if not CLEAN23
    procedure AfterResourceFindCost(var ResourceCost: Record "Price List Line");
    begin
        OnAfterResourceFindCost(Rec, ResourceCost);
    end;
#endif

    protected procedure RetrieveCostPrice(CalledByFieldNo: Integer): Boolean
    var
        ShouldRetrieveCostPrice: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        ShouldRetrieveCostPrice := false;
        OnBeforeRetrieveCostPrice(Rec, xRec, ShouldRetrieveCostPrice, IsHandled, CalledByFieldNo);
        if IsHandled then
            exit(ShouldRetrieveCostPrice);

        if CalledByFieldNo <> 0 then
            case Type of
                Type::Item:
                    if not (CalledByFieldNo in
                            [FieldNo("No."), FieldNo(Quantity), FieldNo("Location Code"),
                            FieldNo("Variant Code"), FieldNo("Unit of Measure Code")])
                    then
                        exit(false);
                Type::Resource:
                    if not (CalledByFieldNo in
                         [FieldNo("No."), FieldNo(Quantity), FieldNo("Work Type Code"), FieldNo("Unit of Measure Code")])
                    then
                        exit(false);
                Type::"G/L Account":
                    if not (CalledByFieldNo in [FieldNo("No."), FieldNo(Quantity)]) then
                        exit(false);
            end;

        case Type of
            Type::Item:
                ShouldRetrieveCostPrice :=
                    ("No." <> xRec."No.") or
                    IsQuantityChangedForPrice() or
                    ("Location Code" <> xRec."Location Code") or
                    ("Variant Code" <> xRec."Variant Code") or
                    (not BypassQtyValidation and (Quantity <> xRec.Quantity)) or
                    ("Unit of Measure Code" <> xRec."Unit of Measure Code");
            Type::Resource:
                ShouldRetrieveCostPrice :=
                    ("No." <> xRec."No.") or
                    IsQuantityChangedForPrice() or
                    ("Work Type Code" <> xRec."Work Type Code") or
                    ("Unit of Measure Code" <> xRec."Unit of Measure Code");
            Type::"G/L Account":
                ShouldRetrieveCostPrice :=
                    ("No." <> xRec."No.") or
                    IsQuantityChangedForPrice();
            else
                exit(false);
        end;
        exit(ShouldRetrieveCostPrice);
    end;

    local procedure IsQuantityChangedForPrice(): Boolean;
#if not CLEAN23
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
#endif
    begin
        if Quantity = xRec.Quantity then
            exit(false);
#if not CLEAN23
        exit(PriceCalculationMgt.IsExtendedPriceCalculationEnabled());
#else
        exit(true);
#endif
    end;

    local procedure UpdateTotalCost()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateTotalCost(Rec, AmountRoundingPrecisionFCY, AmountRoundingPrecision, IsHandled);
        if IsHandled then
            exit;

        "Total Cost" := Round("Unit Cost" * Quantity, AmountRoundingPrecisionFCY);
        "Total Cost (LCY)" := ConvertAmountToLCY("Total Cost", AmountRoundingPrecision);
    end;

    procedure FindPriceAndDiscount(CalledByFieldNo: Integer)
    var
        PriceType: Enum "Price Type";
        IsHandled: Boolean;
    begin
        if RetrieveCostPrice(CalledByFieldNo) and ("No." <> '') then begin
            IsHandled := false;
            OnBeforeFindPriceAndDiscount(CalledByFieldNo, IsHandled, Rec, xRec);
            if IsHandled then
                exit;

            ApplyPrice(PriceType::Sale, CalledByFieldNo);
            ApplyPrice(PriceType::Purchase, CalledByFieldNo);
            if Type = Type::Resource then begin
                "Unit Cost (LCY)" := ConvertAmountToLCY("Unit Cost", UnitAmountRoundingPrecision);
                "Direct Unit Cost (LCY)" := ConvertAmountToLCY("Direct Unit Cost (LCY)", UnitAmountRoundingPrecision);
            end;
            OnAfterFindPriceAndDiscount(Rec, xRec, CalledByFieldNo);
        end;
    end;

    procedure ApplyPrice(PriceType: enum "Price Type"; CalledByFieldNo: Integer)
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        LineWithPrice: Interface "Line With Price";
        PriceCalculation: Interface "Price Calculation";
        Line: Variant;
    begin
        GetLineWithPrice(LineWithPrice);
        LineWithPrice.SetLine(PriceType, Rec);
        PriceCalculationMgt.GetHandler(LineWithPrice, PriceCalculation);
        PriceCalculation.ApplyPrice(CalledByFieldNo);
        if PriceType = PriceType::Sale then
            PriceCalculation.ApplyDiscount();
        PriceCalculation.GetLine(Line);
        Rec := Line;
    end;

    procedure GetLineWithPrice(var LineWithPrice: Interface "Line With Price")
    var
        ContratoPlanningLinePrice: Codeunit "Contrato Planning Line - Price";
    begin
        LineWithPrice := ContratoPlanningLinePrice;
        OnAfterGetLineWithPrice(LineWithPrice);
    end;

    local procedure HandleCostFactor()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHandleCostFactor(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if ("Cost Factor" <> 0) and
           ((("Unit Cost" <> xRec."Unit Cost") or ("Cost Factor" <> xRec."Cost Factor")) or
            ((Quantity <> xRec.Quantity) or ("Location Code" <> xRec."Location Code")))
        then
            "Unit Price" := Round("Unit Cost" * "Cost Factor", UnitAmountRoundingPrecisionFCY)
        else
            if (Item."Price/Profit Calculation" = Item."Price/Profit Calculation"::"Price=Cost+Profit") and
               (Item."Profit %" < 100) and
               ("Unit Cost" <> xRec."Unit Cost")
            then
                "Unit Price" := Round("Unit Cost" / (1 - Item."Profit %" / 100), UnitAmountRoundingPrecisionFCY);

        OnAfterHandleCostFactor(Rec, xRec, Item);
    end;

    local procedure UpdateUnitPrice()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateUnitPrice(Rec, xRec, IsHandled);
        if not IsHandled then begin
            GetContrato();
            RecalculateAmounts(Contrato."Exch. Calculation (Price)", xRec."Unit Price", "Unit Price", "Unit Price (LCY)");
        end;
        OnAfterUpdateUnitPrice(Rec, xRec, AmountRoundingPrecision, AmountRoundingPrecisionFCY);
    end;

    local procedure RecalculateAmounts(ContratoExchCalculation: Option "Fixed FCY","Fixed LCY"; xAmount: Decimal; var Amount: Decimal; var AmountLCY: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRecalculateAmounts(Rec, xRec, AmountLCY, IsHandled, Amount);
        if IsHandled then
            exit;

        if (xRec."Currency Factor" <> "Currency Factor") and
           (Amount = xAmount) and (ContratoExchCalculation = ContratoExchCalculation::"Fixed LCY")
        then
            Amount := ConvertAmountToFCY(AmountLCY, UnitAmountRoundingPrecisionFCY)
        else
            AmountLCY := ConvertAmountToLCY(Amount, UnitAmountRoundingPrecision);
    end;

    local procedure ConvertAmountToFCY(AmountLCY: Decimal; Precision: Decimal) AmountFCY: Decimal;
    begin
        AmountFCY :=
            Round(
                CurrExchRate.ExchangeAmtLCYToFCY(
                    "Currency Date", "Currency Code", AmountLCY, "Currency Factor"),
                Precision);
    end;

    local procedure ConvertAmountToLCY(AmountFCY: Decimal; Precision: Decimal): Decimal;
    begin
        exit(ConvertAmountToLCY("Currency Date", AmountFCY, "Currency Factor", Precision));
    end;

    local procedure ConvertAmountToLCY(PostingDate: Date; AmountFCY: Decimal; CurrencyFactor: Decimal; Precision: Decimal) AmountLCY: Decimal;
    begin
        AmountLCY :=
            Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                    PostingDate, "Currency Code", AmountFCY, CurrencyFactor),
                Precision);
    end;

    local procedure UpdateTotalPrice()
    begin
        "Total Price" := Round(Quantity * "Unit Price", AmountRoundingPrecisionFCY);
        "Total Price (LCY)" := ConvertAmountToLCY("Total Price", AmountRoundingPrecision);
        OnAfterUpdateTotalPrice(Rec);
    end;

    procedure UpdateAmountsAndDiscounts()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateAmountsAndDiscounts(Rec, xRec, IsHandled);
        if not IsHandled then begin
            // Patch for fixing Edit-in-Excel issues due to dependency on xRec. 
            if not GuiAllowed() then
                if xRec.Get(xRec.RecordId()) then;

            if "Total Price" = 0 then begin
                "Line Amount" := 0;
                "Line Discount Amount" := 0;
            end else
                if ("Line Amount" <> xRec."Line Amount") and ("Line Discount Amount" = xRec."Line Discount Amount") then begin
                    "Line Amount" := Round("Line Amount", AmountRoundingPrecisionFCY);
                    "Line Discount Amount" := "Total Price" - "Line Amount";
                    "Line Discount %" :=
                      Round("Line Discount Amount" / "Total Price" * 100, 0.00001);
                end else
                    if ("Line Discount Amount" <> xRec."Line Discount Amount") and ("Line Amount" = xRec."Line Amount") then begin
                        "Line Discount Amount" := Round("Line Discount Amount", AmountRoundingPrecisionFCY);
                        "Line Amount" := "Total Price" - "Line Discount Amount";
                        "Line Discount %" :=
                          Round("Line Discount Amount" / "Total Price" * 100, 0.00001);
                    end else
                        if ("Line Discount Amount" = xRec."Line Discount Amount") and
                           (("Line Amount" <> xRec."Line Amount") or ("Line Discount %" <> xRec."Line Discount %") or
                            ("Total Price" <> xRec."Total Price"))
                        then begin
                            "Line Discount Amount" :=
                              Round("Total Price" * "Line Discount %" / 100, AmountRoundingPrecisionFCY);
                            "Line Amount" := "Total Price" - "Line Discount Amount";
                        end;

            "Line Amount (LCY)" := ConvertAmountToLCY("Line Amount", AmountRoundingPrecision);
            "Line Discount Amount (LCY)" := ConvertAmountToLCY("Line Discount Amount", AmountRoundingPrecision);
        end;
        OnAfterUpdateAmountsAndDiscounts(Rec, xRec);
    end;

    procedure Use(PostedQty: Decimal; PostedTotalCost: Decimal; PostedLineAmount: Decimal; PostingDate: Date; CurrencyFactor: Decimal)
    begin
        if "Usage Link" then begin
            InitRoundingPrecisions();
            // Update Quantity Posted
            Validate("Qty. Posted", "Qty. Posted" + PostedQty);

            // Update Posted Costs and Amounts.
            "Posted Total Cost" += Round(PostedTotalCost, AmountRoundingPrecisionFCY);
            "Posted Total Cost (LCY)" :=
                ConvertAmountToLCY(
                    PostingDate, "Posted Total Cost", CurrencyFactor, AmountRoundingPrecision);

            "Posted Line Amount" += Round(PostedLineAmount, AmountRoundingPrecisionFCY);
            "Posted Line Amount (LCY)" :=
                ConvertAmountToLCY(
                    PostingDate, "Posted Line Amount", CurrencyFactor, AmountRoundingPrecision);

            // Update Remaining Quantity
            UpdateRemainingQuantityFromUse(PostedQty);

            // Update Remaining Costs and Amounts
            UpdateRemainingCostsAndAmounts(PostingDate, CurrencyFactor);

            // Update Quantity to Post
            Validate("Qty. to Transfer to Journal", "Remaining Qty.");

            // Update Qty. Pick for location with optional warehouse pick.
            UpdateQtyPickedForOptionalWhsePick("Qty. Posted");

        end else
            ClearValues();

        OnUseOnBeforeModify(Rec, xRec, AmountRoundingPrecision, UnitAmountRoundingPrecision, AmountRoundingPrecisionFCY, UnitAmountRoundingPrecisionFCY);
        Modify(true);
    end;

    local procedure UpdateQtyPickedForOptionalWhsePick(QtyPosted: Decimal)
    begin
        GetLocation("Location Code");
        if Location."Job Consump. Whse. Handling" <> Location."Job Consump. Whse. Handling"::"Warehouse Pick (mandatory)" then
            if ("Qty. Picked" < QtyPosted) then
                Validate("Qty. Picked", QtyPosted);
    end;

    local procedure UpdateRemainingQuantityFromUse(PostedQty: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateRemainingQuantityFromUse(Rec, xRec, PostedQty, IsHandled);
        if IsHandled then
            exit;

        if (PostedQty >= 0) = ("Remaining Qty." >= 0) then
            if Abs(PostedQty) <= Abs("Remaining Qty.") then
                Validate("Remaining Qty.", "Remaining Qty." - PostedQty)
            else begin
                Validate(Quantity, Quantity + PostedQty - "Remaining Qty.");
                Validate("Remaining Qty.", 0);
            end
        else
            Validate("Remaining Qty.", "Remaining Qty." - PostedQty);
    end;

    local procedure UpdateRemainingCostsAndAmounts(PostingDate: Date; CurrencyFactor: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateRemainingCostsAndAmounts(Rec, PostingDate, CurrencyFactor, AmountRoundingPrecisionFCY, AmountRoundingPrecision, IsHandled);
        if IsHandled then
            exit;

        if "Usage Link" then begin
            InitRoundingPrecisions();
            "Remaining Total Cost" := Round("Unit Cost" * "Remaining Qty.", AmountRoundingPrecisionFCY);
            "Remaining Total Cost (LCY)" :=
                ConvertAmountToLCY(
                    PostingDate, "Remaining Total Cost", CurrencyFactor, AmountRoundingPrecision);
            "Remaining Line Amount" := CalcLineAmount("Remaining Qty.");
            "Remaining Line Amount (LCY)" :=
                ConvertAmountToLCY(
                    PostingDate, "Remaining Line Amount", CurrencyFactor, AmountRoundingPrecision);
        end else
            ClearValues();
    end;

    local procedure UpdateRemainingQuantity()
    var
        Delta: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateRemainingQuantity(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "Usage Link" and (xRec."No." = "No.") then begin
            Delta := Quantity - xRec.Quantity;
            Validate("Remaining Qty.", "Remaining Qty." + Delta);
            Validate("Qty. to Transfer to Journal", "Qty. to Transfer to Journal" + Delta);
        end;
    end;

    procedure UpdateQtyToTransfer()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateQtyToTransfer(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if "Contract Line" then begin
            CalcFields("Qty. Transferred to Invoice");
            Validate("Qty. to Transfer to Invoice", Quantity - "Qty. Transferred to Invoice");
        end else
            Validate("Qty. to Transfer to Invoice", 0);
    end;

    procedure UpdateQtyToInvoice()
    begin
        if "Contract Line" then begin
            CalcFields("Qty. Invoiced");
            Validate("Qty. to Invoice", Quantity - "Qty. Invoiced")
        end else
            Validate("Qty. to Invoice", 0);
    end;

    procedure UpdatePostedTotalCost(AdjustContratoCost: Decimal; AdjustContratoCostLCY: Decimal)
    begin
        if "Usage Link" then begin
            InitRoundingPrecisions();
            "Posted Total Cost" += Round(AdjustContratoCost, AmountRoundingPrecisionFCY);
            "Posted Total Cost (LCY)" += Round(AdjustContratoCostLCY, AmountRoundingPrecision);
        end;
    end;

    procedure ValidateModification(FieldChanged: Boolean; FieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateModification(Rec, IsHandled, xRec, FieldNo);
        if IsHandled then
            exit;

        if FieldChanged then begin
            CalcFields("Qty. Transferred to Invoice");
            TestField("Qty. Transferred to Invoice", 0);
        end;

        OnAfterValidateModification(Rec, FieldChanged, FieldNo);
    end;

    local procedure CheckUsageLinkRelations()
    var
        ContratoUsageLink: Record "Contrato Usage Link";
    begin
        ContratoUsageLink.SetRange("Contrato No.", "Contrato No.");
        ContratoUsageLink.SetRange("Contrato Task No.", "Contrato Task No.");
        ContratoUsageLink.SetRange("Line No.", "Line No.");
        if not ContratoUsageLink.IsEmpty() then
            Error(LinkedContratoLedgerErr);
    end;

    local procedure ControlUsageLink()
    var
        ContratoUsageLink: Record "Contrato Usage Link";
        IsHandled: Boolean;
    begin
        GetContrato();

        IsHandled := false;
        OnControlUsageLinkOnAfterGetContrato(Rec, Contrato, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if Contrato."Apply Usage Link" then begin
            if "Schedule Line" then
                "Usage Link" := true
            else
                "Usage Link" := false;
        end else
            if not "Schedule Line" then
                "Usage Link" := false;

        ContratoUsageLink.SetRange("Contrato No.", "Contrato No.");
        ContratoUsageLink.SetRange("Contrato Task No.", "Contrato Task No.");
        ContratoUsageLink.SetRange("Line No.", "Line No.");
        IsHandled := false;
        OnControlUsageLinkOnAfterSetFilterContratoUsageLink(Rec, ContratoUsageLink, Contrato, CurrFieldNo, IsHandled);
        if not IsHandled then
            if not ContratoUsageLink.IsEmpty() and not "Usage Link" then
                Error(ControlUsageLinkErr, TableCaption(), FieldCaption("Schedule Line"), FieldCaption("Usage Link"));

        Validate("Remaining Qty.", Quantity - "Qty. Posted");
        Validate("Qty. to Transfer to Journal", Quantity - "Qty. Posted");
        UpdateRemainingCostsAndAmounts("Currency Date", "Currency Factor");

        UpdateQtyToTransfer();
        UpdateQtyToInvoice();

        OnAfterControlUsageLink(Rec, Contrato, CurrFieldNo);
    end;

    local procedure CalcLineAmount(Qty: Decimal): Decimal
    var
        TotalPrice: Decimal;
    begin
        InitRoundingPrecisions();
        TotalPrice := Round(Qty * "Unit Price", AmountRoundingPrecisionFCY);
        exit(TotalPrice - Round(TotalPrice * "Line Discount %" / 100, AmountRoundingPrecisionFCY));
    end;

    procedure Overdue(): Boolean
    begin
        if ("Planning Date" < WorkDate()) and ("Remaining Qty." > 0) then
            exit(true);
        exit(false);
    end;

    procedure SetBypassQtyValidation(Bypass: Boolean)
    begin
        BypassQtyValidation := Bypass;
    end;

    procedure UpdateReservation(CalledByFieldNo: Integer)
    var
        ReservationCheckDateConfl: Codeunit "Reservation-Check Date Confl.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateReservation(Rec, xRec, CalledByFieldNo, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        if (CurrFieldNo <> CalledByFieldNo) and (CurrFieldNo <> 0) then
            exit;

        case CalledByFieldNo of
            FieldNo("Planning Date"), FieldNo("Planned Delivery Date"):
                if (xRec."Planning Date" <> "Planning Date") and
                   (Quantity <> 0) and
                   (Reserve <> Reserve::Never)
                then
                    Reserve := Contrato.Reserve;
            //ReservationCheckDateConfl.ContratoPlanningLineCheck(Rec, true);
            FieldNo(Quantity):
                Reserve := Contrato.Reserve;
            //ContratoPlanningLineReserve.VerifyQuantity(Rec, xRec);
            FieldNo("Usage Link"):
                if (Type = Type::Item) and "Usage Link" then begin
                    GetItem();
                    if Item.Reserve = Item.Reserve::Optional then begin
                        GetContrato();
                        Reserve := Contrato.Reserve
                    end else
                        Reserve := Item.Reserve;
                end else
                    Reserve := Reserve::Never;
        end;
        //ContratoPlanningLineReserve.VerifyChange(Rec, xRec);
        UpdatePlanned();
    end;

    local procedure UpdateDescription()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDescription(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if (xRec.Type = xRec.Type::Resource) and (xRec."No." <> '') then begin
            Res.Get(xRec."No.");
            if Description = Res.Name then
                Description := '';
            if "Description 2" = Res."Name 2" then
                "Description 2" := '';
        end;
    end;

    procedure ShowReservation()
    var
        Reservation: Page Reservation;
    begin
        TestField(Type, Type::Item);
        TestField("No.");
        TestField(Reserve);
        TestField("Usage Link");
        Reservation.SetReservSource(Rec);
        Reservation.RunModal();
    end;

    procedure ShowReservationEntries(Modal: Boolean)
    var
        ReservEntry: Record "Reservation Entry";
    begin
        TestField(Type, Type::Item);
        TestField("No.");
        ReservEntry.InitSortingAndFilters(true);
        SetReservationFilters(ReservEntry);
        if Modal then
            PAGE.RunModal(PAGE::"Reservation Entries", ReservEntry)
        else
            PAGE.Run(PAGE::"Reservation Entries", ReservEntry);
    end;

    procedure AutoReserve()
    var
        ReservMgt: Codeunit "Reservation Management";
        FullAutoReservation: Boolean;
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
    begin
        TestField(Type, Type::Item);
        TestField("No.");
        if Reserve = Reserve::Never then
            FieldError(Reserve);
        //ContratoPlanningLineReserve.ReservQuantity(Rec, QtyToReserve, QtyToReserveBase);
        if QtyToReserveBase <> 0 then begin
            TestField("Planning Date");
            ReservMgt.SetReservSource(Rec);
            ReservMgt.AutoReserve(FullAutoReservation, '', "Planning Date", QtyToReserve, QtyToReserveBase);
            Find();
            if not FullAutoReservation then begin
                Commit();
                if Confirm(AutoReserveQst, true) then begin
                    Rec.ShowReservation();
                    Find();
                end;
            end;
            UpdatePlanned();
        end;
    end;

    procedure ShowTracking()
    var
        OrderTrackingForm: Page "Order Tracking";
    begin
        //OrderTrackingForm.SetContratoPlanningLine(Rec);
        OrderTrackingForm.RunModal();
    end;

    procedure ShowOrderPromisingLine()
    var
        OrderPromisingLine: Record "Order Promising Line";
        OrderPromisingLines: Page "Order Promising Lines";
    begin
        OrderPromisingLine.SetRange("Source Type", OrderPromisingLine."Source Type"::Job);
        OrderPromisingLine.SetRange("Source Type", OrderPromisingLine."Source Type"::Job);
        OrderPromisingLine.SetRange("Source ID", "Contrato No.");
        OrderPromisingLine.SetRange("Source Line No.", "Contrato Contract Entry No.");

        OrderPromisingLines.SetSource(OrderPromisingLine."Source Type"::Job);
        OrderPromisingLines.SetTableView(OrderPromisingLine);
        OrderPromisingLines.RunModal();
    end;

    procedure FilterLinesWithItemToPlan(var Item: Record Item)
    begin
        Reset();
        SetCurrentKey(Status, Type, "No.", "Variant Code", "Location Code", "Planning Date");
        SetRange(Status, Status::Order);
        SetRange(Type, Type::Item);
        SetRange("No.", Item."No.");
        SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        SetFilter("Location Code", Item.GetFilter("Location Filter"));
        SetFilter("Planning Date", Item.GetFilter("Date Filter"));
        SetFilter("Remaining Qty. (Base)", '<>0');
        SetFilter("Unit of Measure Code", Item.GetFilter("Unit of Measure Filter"));

        OnAfterFilterLinesWithItemToPlan(Rec, Item);
    end;

    procedure FindLinesWithItemToPlan(var Item: Record Item): Boolean
    begin
        FilterLinesWithItemToPlan(Item);
        exit(Find('-'));
    end;

    procedure LinesWithItemToPlanExist(var Item2: Record Item): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeLinesWithItemToPlanExist(Item2, Result, IsHandled);
        if IsHandled then
            exit(Result);

        FilterLinesWithItemToPlan(Item2);
        exit(not IsEmpty);
    end;

    procedure FilterLinesForReservation(ReservationEntry: Record "Reservation Entry"; NewStatus: Option; AvailabilityFilter: Text; Positive: Boolean)
    begin
        Reset();
        SetCurrentKey(Status, Type, "No.", "Variant Code", "Location Code", "Planning Date");
        SetRange(Status, NewStatus);
        SetRange(Type, Type::Item);
        SetRange("No.", ReservationEntry."Item No.");
        SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange("Location Code", ReservationEntry."Location Code");
        SetFilter("Planning Date", AvailabilityFilter);
        if Positive then
            SetFilter("Quantity (Base)", '<0')
        else
            SetFilter("Quantity (Base)", '>0');

        OnAfterFilterLinesForReservation(Rec, ReservationEntry, NewStatus, AvailabilityFilter, Positive);
    end;

    procedure DrillDownContratoInvoices()
    var
        ContratoInvoices: Page "Contrato Invoices";
    begin
        ContratoInvoices.SetShowDetails(false);
        //ContratoInvoices.SetPrContratoPlanningLine(Rec);
        ContratoInvoices.Run();
    end;

    local procedure CheckRelatedContratoPlanningLineInvoice()
    var
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckRelatedContratoPlanningLineInvoice(Rec, IsHandled);
        if IsHandled then
            exit;

        ContratoPlanningLineInvoice.SetRange("Contrato No.", "Contrato No.");
        ContratoPlanningLineInvoice.SetRange("Contrato Task No.", "Contrato Task No.");
        ContratoPlanningLineInvoice.SetRange("Contrato Planning Line No.", "Line No.");
        if not ContratoPlanningLineInvoice.IsEmpty() then
            Error(NotPossibleContratoPlanningLineErr);
    end;

    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(
          ItemTrackingMgt.ComposeRowID(Database::"Contrato Planning Line", Status.AsInteger(),
            "Contrato No.", '', 0, "Contrato Contract Entry No."));
    end;

    internal procedure RowID2(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(
          ItemTrackingMgt.ComposeRowID(Database::Contrato, 0, "Contrato No.", '', 0, "Contrato Contract Entry No."));
    end;

    procedure UpdatePlanned(): Boolean
    begin
        CalcFields("Reserved Quantity");
        if Planned = ("Reserved Quantity" = "Remaining Qty.") then
            exit(false);
        Planned := not Planned;
        exit(true);
    end;

    procedure UpdatePlannedDueDate() Changed: Boolean;
    var
        Customer: Record Customer;
        PaymentTerms: Record "Payment Terms";
        DueDateCalculation: DateFormula;
        xPlanningDueDate: Date;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdatePlannedDueDate(Rec, Changed, IsHandled);
        if IsHandled then
            exit(Changed);

        xPlanningDueDate := "Planning Due Date";
        if "Planning Date" = 0D then
            exit(false);
        "Planning Due Date" := "Planning Date";
        GetContrato();
        if Contrato."No." = '' then
            exit(false);
        Customer.SetLoadFields("Payment Terms Code");
        if not Customer.Get(Contrato."Bill-to Customer No.") then
            exit(false);
        PaymentTerms.SetLoadFields("Due Date Calculation");
        if PaymentTerms.Get(Customer."Payment Terms Code") then begin
            //PaymentTerms.GetDueDateCalculation(DueDateCalculation);
            "Planning Due Date" := CalcDate(DueDateCalculation, "Planning Date");
        end;
        exit("Planning Due Date" <> xPlanningDueDate);
    end;

    procedure ClearValues()
    begin
        Validate("Remaining Qty.", 0);
        "Remaining Total Cost" := 0;
        "Remaining Total Cost (LCY)" := 0;
        "Remaining Line Amount" := 0;
        "Remaining Line Amount (LCY)" := 0;
        Validate("Qty. Posted", 0);
        Validate("Qty. to Transfer to Journal", 0);
        "Posted Total Cost" := 0;
        "Posted Total Cost (LCY)" := 0;
        "Posted Line Amount" := 0;
        "Posted Line Amount (LCY)" := 0;

        OnAfterClearValues(Rec);
    end;

    procedure ClearTracking()
    begin
        "Serial No." := '';
        "Lot No." := '';

        OnAfterClearTracking(Rec);
    end;

    procedure InitFromContratoPlanningLine(FromContratoPlanningLine: Record "Contrato Planning Line"; NewQuantity: Decimal)
    var
        ToContratoPlanningLine: Record "Contrato Planning Line";
        ContratoJnlManagement: Codeunit ContratoJnlManagement;
    begin
        ToContratoPlanningLine := Rec;

        ToContratoPlanningLine.Init();
        ToContratoPlanningLine.TransferFields(FromContratoPlanningLine);
        ToContratoPlanningLine."Line No." := GetNextContratoLineNo(FromContratoPlanningLine);
        ToContratoPlanningLine.Validate("Line Type", "Line Type"::Billable);
        ToContratoPlanningLine.ClearValues();
        ToContratoPlanningLine."Contrato Contract Entry No." := ContratoJnlManagement.GetNextEntryNo();
        if ToContratoPlanningLine.Type <> ToContratoPlanningLine.Type::Text then begin
            ToContratoPlanningLine.Validate(Quantity, NewQuantity);
            ToContratoPlanningLine.Validate("Currency Code", FromContratoPlanningLine."Currency Code");
            ToContratoPlanningLine.Validate("Currency Date", FromContratoPlanningLine."Currency Date");
            ToContratoPlanningLine.Validate("Currency Factor", FromContratoPlanningLine."Currency Factor");
            ToContratoPlanningLine.Validate("Unit Cost", FromContratoPlanningLine."Unit Cost");
            ToContratoPlanningLine.Validate("Unit Price", FromContratoPlanningLine."Unit Price");
            if FromContratoPlanningLine."Line Discount %" <> 0 then
                ToContratoPlanningLine.Validate("Line Discount %", FromContratoPlanningLine."Line Discount %");
        end;

        OnAfterInitFromContratoPlanningLine(ToContratoPlanningLine, FromContratoPlanningLine);
        Rec := ToContratoPlanningLine;
    end;

    protected procedure GetNextContratoLineNo(FromContratoPlanningLine: Record "Contrato Planning Line"): Integer
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoPlanningLine.SetRange("Contrato No.", FromContratoPlanningLine."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", FromContratoPlanningLine."Contrato Task No.");
        if ContratoPlanningLine.FindLast() then;
        exit(ContratoPlanningLine."Line No." + 10000);
    end;

    procedure IsInventoriableItem(): Boolean
    begin
        if Type <> Type::Item then
            exit(false);
        if "No." = '' then
            exit(false);
        GetItem();
        exit(Item.IsInventoriableType());
    end;

    procedure IsNonInventoriableItem(): Boolean
    begin
        if Type <> Type::Item then
            exit(false);
        if "No." = '' then
            exit(false);
        GetItem();
        exit(Item.IsNonInventoriableType());
    end;

    procedure ConvertToContratoLineType() ContratoLineType: Enum "Contrato Line Type"
    begin
        ContratoLineType := Enum::"Contrato Line Type".FromInteger("Line Type".AsInteger() + 1);

        OnAfterConvertToContratoLineType(Rec, ContratoLineType);
    end;

    procedure ConvertFromContratoLineType(ContratoLineType: Enum "Contrato Line Type") ContratoPlanningLineLineType: Enum ContratoPlanningLineLineType
    begin
        ContratoPlanningLineLineType := Enum::ContratoPlanningLineLineType.FromInteger(ContratoLineType.AsInteger() - 1);

        OnAfterConvertFromContratoLineType(Rec, ContratoLineType, ContratoPlanningLineLineType);
    end;

    procedure CopyTrackingFromContratoJnlLine(ContratoJnlLine: Record "Contrato Journal Line")
    begin
        "Serial No." := ContratoJnlLine."Serial No.";
        "Lot No." := ContratoJnlLine."Lot No.";

        OnAfterCopyTrackingFromContratoJnlLine(Rec, ContratoJnlLine);
    end;

    procedure CopyTrackingFromContratoLedgEntry(ContratoLedgEntry: Record "Contrato Ledger Entry")
    begin
        "Serial No." := ContratoLedgEntry."Serial No.";
        "Lot No." := ContratoLedgEntry."Lot No.";

        OnAfterCopyTrackingFromContratoLedgEntry(Rec, ContratoLedgEntry);
    end;

    local procedure SetDefaultBin()
    begin
        if (Rec."No." <> '') then begin
            GetItem();
            if Item.IsInventoriableType() then
                Validate("Bin Code", FindBin());
        end;
    end;

    local procedure FindBin() NewBinCode: Code[20]
    var
        WMSManagement: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindBin(Rec, NewBinCode, IsHandled);
        if IsHandled then
            exit(NewBinCode);

        if (Rec."No." <> '') and (Rec."Location Code" <> '') then begin
            if FindBinFromContratoTask(NewBinCode) then
                exit(NewBinCode);
            GetLocation(Rec."Location Code");
            if Location."To-Job Bin Code" <> '' then
                NewBinCode := Location."To-Job Bin Code"
            else
                if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                    WMSManagement.GetDefaultBin(Rec."No.", Rec."Variant Code", Rec."Location Code", NewBinCode);
        end;
    end;

    local procedure FindBinFromContratoTask(var NewBinCode: Code[20]): Boolean
    begin
        if ContratoTask.Get(Rec."Contrato No.", Rec."Contrato Task No.") and (ContratoTask."Bin Code" <> '')
            and ("Location Code" = ContratoTask."Location Code") then begin
            NewBinCode := ContratoTask."Bin Code";
            exit(true);
        end;
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    local procedure DeleteWarehouseRequest(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoPlanningLine2: Record "Contrato Planning Line";
        WarehouseRequest: Record "Warehouse Request";
        WhsePickRequest: Record "Whse. Pick Request";
    begin
        ContratoPlanningLine2.SetFilter("Contrato Contract Entry No.", '<>%1', ContratoPlanningLine."Contrato Contract Entry No.");
        ContratoPlanningLine2.SetRange("Contrato No.", ContratoPlanningLine."Contrato No.");
        ContratoPlanningLine2.SetRange("Location Code", ContratoPlanningLine."Location Code");

        if ContratoPlanningLine2.IsEmpty() then
            if WarehouseRequest.Get(Enum::"Warehouse Request Type"::Outbound, ContratoPlanningLine."Location Code", Database::Contrato, 0, ContratoPlanningLine."Contrato No.") then
                WarehouseRequest.Delete(true)
            else
                if WhsePickRequest.Get(WhsePickRequest."Document Type"::Job, 0, ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Location Code") then
                    WhsePickRequest.Delete(true);
    end;

    internal procedure CreateWarehouseRequest()
    var
        WhsePickRequest: Record "Whse. Pick Request";
        WarehouseRequest: Record "Warehouse Request";
    begin
        if Rec."Location Code" = '' then
            exit;

        GetLocation(Rec."Location Code");

        case Location."Job Consump. Whse. Handling" of
            Enum::"Job Consump. Whse. Handling"::"Warehouse Pick (mandatory)",
            Enum::"Job Consump. Whse. Handling"::"Warehouse Pick (optional)":
                if not WhsePickRequest.Get(WhsePickRequest."Document Type"::Job, 0, Rec."Contrato No.", Rec."Location Code") then begin
                    WhsePickRequest.Init();
                    WhsePickRequest."Document Type" := WhsePickRequest."Document Type"::Job;
                    WhsePickRequest."Document Subtype" := 0;
                    WhsePickRequest."Document No." := Rec."Contrato No.";
                    WhsePickRequest.Status := WhsePickRequest.Status::Released;
                    WhsePickRequest."Location Code" := Location.Code;
                    if WhsePickRequest.Insert() then;
                end;
            Enum::"Job Consump. Whse. Handling"::"Inventory Pick":
                if not GetWarehouseRequest(WarehouseRequest) then begin
                    WarehouseRequest.Init();
                    WarehouseRequest.Type := WarehouseRequest.Type::Outbound;
                    WarehouseRequest."Location Code" := Rec."Location Code";
                    WarehouseRequest."Source Type" := Database::Contrato;
                    WarehouseRequest."Source No." := Rec."Contrato No.";
                    WarehouseRequest."Source Subtype" := 0;
                    WarehouseRequest."Source Document" := WarehouseRequest."Source Document"::"Job Usage";
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    if WarehouseRequest.Insert() then;
                end;
        end;
    end;

    local procedure GetWarehouseRequest(var WarehouseRequest: Record "Warehouse Request"): Boolean
    begin
        if WarehouseRequest.Get(WarehouseRequest.Type::Outbound, Rec."Location Code", Database::Contrato, 0, Rec."Contrato No.") then
            if (WarehouseRequest."Source Document" = WarehouseRequest."Source Document"::"Job Usage") and (WarehouseRequest."Document Status" = WarehouseRequest."Document Status"::Released) then
                exit(true);
    end;

    procedure TestStatusOpen()
    begin
        TestField(Status, Status::Order);
        GetContrato();
        Contrato.TestField(Status, Contrato.Status::Open);
    end;

    procedure CheckIfContratoPlngLineMeetsReservedFromStockSetting(QtyToPost: Decimal; ReservedFromStock: Enum "Reservation From Stock") Result: Boolean
    var
        QtyReservedFromStock: Decimal;
    begin
        Result := true;

        if not Rec.IsInventoriableItem() then
            exit(true);

        if ReservedFromStock = ReservedFromStock::" " then
            exit(true);

        QtyReservedFromStock := ContratoPlanningLineReserve.GetReservedQtyFromInventory(Rec);

        case ReservedFromStock of
            ReservedFromStock::Full:
                if QtyToPost <> QtyReservedFromStock then
                    Result := false;
            ReservedFromStock::"Full and Partial":
                if QtyReservedFromStock = 0 then
                    Result := false;
            else
                OnCheckIfContratoPlngLineMeetsReservedFromStockSetting(QtyToPost, ReservedFromStock, Result);
        end;

        exit(Result);
    end;

    procedure IsAsmToOrderAllowed() Result: Boolean
    begin
        Result := true;

        if Quantity < 0 then
            Result := false;
        if Type <> Type::Item then
            Result := false;
        if "No." = '' then
            Result := false;
        if "Line Type" = "Line Type"::Billable then
            Result := false;
    end;

    procedure QtyToAsmBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
            exit(AsmHeader."Quantity to Assemble (Base)");
        exit(0);
    end;

    procedure ShowAsmToContratoPlanningLines()
    begin
        ATOLink.ShowAsmToContratoPlanningLines(Rec);
    end;

    procedure CheckAsmToOrder(AsmHeader: Record "Assembly Header")
    begin
        TestField("Qty. to Assemble", AsmHeader.Quantity);
        TestField(Type, Type::Item);
        TestField("No.", AsmHeader."Item No.");
        TestField("Location Code", AsmHeader."Location Code");
        TestField("Unit of Measure Code", AsmHeader."Unit of Measure Code");
        TestField("Variant Code", AsmHeader."Variant Code");
        GetContrato();
        if Contrato.Status = Contrato.Status::Open then begin
            AsmHeader.CalcFields("Reserved Qty. (Base)");
            AsmHeader.TestField("Reserved Qty. (Base)", AsmHeader."Remaining Quantity (Base)");
        end;
        TestField("Qty. to Assemble (Base)", AsmHeader."Quantity (Base)");
        if "Remaining Qty. (Base)" < AsmHeader."Remaining Quantity (Base)" then
            AsmHeader.FieldError("Remaining Quantity (Base)", StrSubstNo(CannotBeMoreErr, "Remaining Qty. (Base)"));
    end;

    procedure AsmToOrderExists(var AsmHeader: Record "Assembly Header"): Boolean
    begin
        if not ATOLink.AsmExistsForContratoPlanningLine(Rec) then
            exit(false);
        exit(AsmHeader.Get(ATOLink."Assembly Document Type", ATOLink."Assembly Document No."));
    end;

    protected procedure InitQtyToAsm()
    var
        Qty, QtyBase : Decimal;
    begin
        if not IsAsmToOrderAllowed() then begin
            "Qty. to Assemble" := 0;
            "Qty. to Assemble (Base)" := 0;
            exit;
        end;

        if ((xRec."Qty. to Assemble (Base)" = 0) and IsAsmToOrderRequired()) or
           ((xRec."Qty. to Assemble (Base)" <> 0) and (xRec."Qty. to Assemble (Base)" = xRec."Quantity (Base)")) or
           ("Qty. to Assemble (Base)" > "Quantity (Base)")
        then begin
            Qty := 0;
            QtyBase := 0;
            AssembledQuantity(Qty, QtyBase);
            "Qty. to Assemble" := Quantity - Qty;
            "Qty. to Assemble (Base)" := "Quantity (Base)" - QtyBase;
        end;
    end;

    procedure AssembledQuantity(var Qty: Decimal; var QtyBase: Decimal)
    var
        PostedATOLink: Record "Posted Assemble-to-Order Link";
    begin
        PostedATOLink.SetCurrentKey("Job No.", "Job Task No.", "Document Line No.");
        PostedATOLink.SetRange("Job No.", Rec."Contrato No.");
        PostedATOLink.SetRange("Job Task No.", Rec."Contrato Task No.");
        PostedATOLink.SetRange("Document Line No.", Rec."Line No.");
        if PostedATOLink.FindSet() then
            repeat
                Qty += PostedATOLink."Assembled Quantity";
                QtyBase += PostedATOLink."Assembled Quantity (Base)";
            until PostedATOLink.Next() = 0;
    end;

    procedure IsAsmToOrderRequired(): Boolean
    begin
        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem();
        if GetSKU() then
            exit(SKU."Assembly Policy" = SKU."Assembly Policy"::"Assemble-to-Order");
        exit(Item."Assembly Policy" = Item."Assembly Policy"::"Assemble-to-Order");
    end;

    procedure SelectMultipleItems()
    var
        ItemListPage: Page "Item List";
        SelectionFilter: Text;
    begin
        OnBeforeSelectMultipleItems(Rec);

        SelectionFilter := ItemListPage.SelectActiveItems();

        if SelectionFilter <> '' then
            AddItems(SelectionFilter);

        OnAfterSelectMultipleItems(Rec);
    end;

    local procedure AddItems(SelectionFilter: Text)
    var
        Item: Record "Item";
        NewContratoPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAddItems(Rec, SelectionFilter, IsHandled);
        if IsHandled then
            exit;

        InitNewLine(NewContratoPlanningLine);
        Item.SetLoadFields("No.");
        Item.SetFilter("No.", SelectionFilter);
        if Item.FindSet() then
            repeat
                AddItem(NewContratoPlanningLine, Item."No.");
            until Item.Next() = 0;
    end;

    procedure GetATOBin(Location: Record Location; var BinCode: Code[20]) Result: Boolean
    var
        AsmHeader: Record "Assembly Header";
    begin
        if not Location."Require Shipment" then
            BinCode := Location."Asm.-to-Order Shpt. Bin Code";
        if BinCode <> '' then
            exit(true);

        if AsmHeader.GetFromAssemblyBin(Location, BinCode) then
            exit(true);

        exit(false);
    end;

    local procedure AddItem(var NewContratoPlanningLine: Record "Contrato Planning Line"; ItemNo: Code[20])
    begin
        NewContratoPlanningLine."Line No." += 10000;
        NewContratoPlanningLine.Validate(Type, NewContratoPlanningLine.Type::Item);
        NewContratoPlanningLine.Validate("No.", ItemNo);
        NewContratoPlanningLine.Insert(true);
    end;

    local procedure InitNewLine(var NewContratoPlanningLine: Record "Contrato Planning Line")
    var
        ExistingContratoPlanningLine: Record "Contrato Planning Line";
    begin
        NewContratoPlanningLine.Copy(Rec);
        ExistingContratoPlanningLine.SetRange("Contrato No.", NewContratoPlanningLine."Contrato No.");
        ExistingContratoPlanningLine.SetRange("Contrato Task No.", NewContratoPlanningLine."Contrato Task No.");
        if ExistingContratoPlanningLine.FindLast() then
            NewContratoPlanningLine."Line No." := ExistingContratoPlanningLine."Line No."
        else
            NewContratoPlanningLine."Line No." := 0;
    end;

    procedure IsExtendedText(): Boolean
    begin
        exit((Type = Type::Text) and ("Attached to Line No." <> 0) and (Quantity = 0));
    end;

    local procedure WhsePickReqForLocation(): Boolean
    begin
        if Rec."Location Code" = '' then
            exit(false);

        GetLocation(Rec."Location Code");
        if Location."Job Consump. Whse. Handling" = Enum::"ContratoConsump.Whse.Handling"::"Warehouse Pick (mandatory)" then
            exit(true);
    end;

    local procedure InitLocation()
    begin
        if ContratoTask.Get(Rec."Contrato No.", Rec."Contrato Task No.") and (ContratoTask."Location Code" <> '') then
            Validate("Location Code", ContratoTask."Location Code");
    end;

    procedure SetSkipCheckForMultipleContratosOnSalesLine(Skip: Boolean)
    begin
        SkipCheckForMultipleContratosOnSalesLine := Skip;
    end;

    procedure GetSkipCheckForMultipleContratosOnSalesLine(): Boolean
    begin
        exit(SkipCheckForMultipleContratosOnSalesLine);
    end;

    local procedure ConfirmDeletion()
    begin
        if CalledFromHeader then
            exit;

        if "Qty. Posted" < "Qty. Picked" then
            if not Confirm(
                StrSubstNo(
                    ConfirmDeleteQst,
                    FieldCaption("Qty. Picked"),
                    "Qty. Picked",
                    FieldCaption("Qty. Posted"),
                    "Qty. Posted",
                    TableCaption),
                false)
            then
                Error('');
    end;

    procedure SuspendDeletionCheck(Suspend: Boolean)
    begin
        CalledFromHeader := Suspend;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateRetrievedCost(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; StockkeepingUnit: Record "Stockkeeping Unit"; Item: Record Item; var RetrievedCost: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromItem(var ContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromGLAccount(var ContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato; GLAccount: Record "G/L Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFieldsFromContrato(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromContratoJnlLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJnlLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConvertToContratoLineType(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoLineType: Enum "Contrato Line Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConvertFromContratoLineType(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoLineType: Enum "Contrato Line Type"; var ContratoPlanningLineLineType: Enum ContratoPlanningLineLineType)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearTracking(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromContratoLedgEntry(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteAmounts(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetContrato(var ContratoPlanningLine: Record "Contrato Planning Line"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSKU(ContratoPlanningLine: Record "Contrato Planning Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetRemainingQty(ContratoPlanningLine: Record "Contrato Planning Line"; var RemainingQty: Decimal; var RemainingQtyBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterLinesWithItemToPlan(var ContratoPlanningLine: Record "Contrato Planning Line"; var Item: Record Item);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterFilterLinesForReservation(var ContratoPlaningLine: Record "Contrato Planning Line"; ReservationEntry: Record "Reservation Entry"; NewStatus: Option; AvailabilityFilter: Text; Positive: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetLineWithPrice(var LineWithPrice: Interface "Line With Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHandleCostFactor(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromContratoPlanningLine(var ToContratoPlanningLine: Record "Contrato Planning Line"; FromContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnAfterResourceFindCost(var ContratoPlanningLine: Record "Contrato Planning Line"; var ResourceCost: Record "Price List Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetReservationFilters(var ReservEntry: Record "Reservation Entry"; ContratoPlanningLine: Record "Contrato Planning Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetupNewLine(var ContratoPlanningLine: Record "Contrato Planning Line"; LastContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAllAmounts(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTotalPrice(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUnitPrice(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var AmountRoundingPrecision: Decimal; var AmountRoundingPrecisionFCY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmountsAndDiscounts(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateModification(var ContratoPlanningLine: Record "Contrato Planning Line"; FieldChanged: Boolean; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcQuantityBase(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckQuantityPosted(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckRelatedContratoPlanningLineInvoice(ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyFromResource(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnsureDirectedPutawayandPickFalse(var ContratoPlanningLine: Record "Contrato Planning Line"; Location: Record Location; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFindPriceAndDiscount(CalledByFieldNo: Integer; var IsHandled: Boolean; var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleCostFactor(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRoundingPrecisions(ContratoPlanningLine: Record "Contrato Planning Line"; var AmountRoundingPrecision: Decimal; var UnitAmountRoundingPrecision: Decimal; var AmountRoundingPrecisionFCY: Decimal; var UnitAmountRoundingPrecisionFCY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecalculateAmounts(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line"; var AmountLCY: Decimal; var IsHandled: Boolean; var Amount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePlannedDueDate(var ContratoPlanningLine: Record "Contrato Planning Line"; var Changed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnInsert(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAmountsAndDiscounts(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDescription(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateModification(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; xContratoPlanningLine: Record "Contrato Planning Line"; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePlanningDate(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQuantityBase(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateWorkTypeCode(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetrieveCostPrice(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var ShouldRetrieveCostPrice: Boolean; var IsHandled: Boolean; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateRemainingQuantity(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateRemainingQuantityFromUse(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; PostedQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAllAmounts(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitCost(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; xContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateReservation(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line"; CalledByFieldNo: Integer; var IsHandled: Boolean; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToTransferToInvoice(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnControlUsageLinkOnAfterGetContrato(var ContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato; CallingFieldNo: Integer; var IsHandling: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateCurrencyFactorOnBeforeGetExchangeRate(ContratoPlanningLine: Record "Contrato Planning Line"; var CurrencyExchangeRate: Record "Currency Exchange Rate")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUseOnBeforeModify(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; AmountRoundingPrecision: Decimal; UnitAmountRoundingPrecision: Decimal; AmountRoundingPrecisionFCY: Decimal; UnitAmountRoundingPrecisionFCY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterCopyFromAccount(var ContratoPlanningLine: Record "Contrato Planning Line"; var xContratoPlanningLine: Record "Contrato Planning Line"; var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLinesWithItemToPlanExist(var Item: Record Item; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateUsageLink(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnAfterSetFilterOnContratoUsageLink(ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoUsageLink: Record "Contrato Usage Link"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRename(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnControlUsageLinkOnAfterSetFilterContratoUsageLink(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoUsageLink: Record "Contrato Usage Link"; Contrato: Record Contrato; CallingFieldNo: Integer; var IsHandling: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindBin(var ContratoPlanningLine: Record "Contrato Planning Line"; var NewBinCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPriceAndDiscount(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCaption(ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; var Result: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckIfContratoPlngLineMeetsReservedFromStockSetting(QtyToPost: Decimal; ReservedFromStock: Enum "Reservation From Stock"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitPrice(var ContratoPlanningLine: Record "Contrato Planning Line"; xContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

#pragma warning disable AS0077
    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateRemainingCostsAndAmounts(var ContratoPlanningLine: Record "Contrato Planning Line"; PostingDate: Date; CurrencyFactor: Decimal; AmountRoundingPrecisionFCY: Decimal; AmountRoundingPrecision: Decimal; var IsHandled: Boolean)
    begin
    end;
#pragma warning restore AS0077

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTotalCost(var ContratoPlanningLine: Record "Contrato Planning Line"; AmountRoundingPrecisionFCY: Decimal; AmountRoundingPrecision: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearValues(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterControlUsageLink(var ContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCopyFromGLAccount(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSelectMultipleItems(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSelectMultipleItems(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddItems(var ContratoPlanningLine: Record "Contrato Planning Line"; SelectionFilter: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromResource(var ContratoPlanningLine: Record "Contrato Planning Line"; Contrato: Record Contrato; Resource: Record Resource)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateQtyToTransfer(var ContratoPlanningLine: Record "Contrato Planning Line"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;
}