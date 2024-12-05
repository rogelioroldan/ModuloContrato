table 50200 Contrato
{
    Caption = 'Contratos';
    DataCaptionFields = "No.", Description;
    DrillDownPageID = "Contrato List";
    LookupPageID = "Contrato List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateNo(Rec, IsHandled);
                if IsHandled then
                    exit;

                if "No." <> xRec."No." then begin
                    ContratosSetup.Get();
                    NoSeries.TestManual(ContratosSetup."Contrato Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := Description;
            end;
        }
        field(4; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(5; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBillToCustomerNo(Rec, IsHandled, xRec, CurrFieldNo);
                if IsHandled then
                    exit;
                BillToCustomerNoUpdated(Rec, xRec);
            end;
        }
        field(12; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(13; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                CheckDate();
            end;
        }
        field(14; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                CheckDate();
            end;
        }
        field(19; Status; Enum "Contrato Status")
        {
            Caption = 'Status';
            InitValue = Open;

            trigger OnValidate()
            var
                ContratoPlanningLine: Record "Contrato Planning Line";
                ATOLink: Record "Assemble-to-OrderLinkContrato";
                ContratoPlanningLineReserve: Codeunit "Contrato Planning Line-Reserve";
                ConfirmManagement: Codeunit "Confirm Management";
                IsHandled: Boolean;
                UndidCompleteStatus: Boolean;
                ShouldDeleteReservationEntries: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateStatus(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if xRec.Status <> Status then begin
                    if Status = Status::Completed then
                        Validate(Complete, true);
                    if xRec.Status = xRec.Status::Completed then begin
                        IsHandled := false;
                        OnValidateStatusOnBeforeConfirm(Rec, xRec, UndidCompleteStatus, IsHandled);
                        if not IsHandled then
                            if ConfirmManagement.GetResponseOrDefault(StatusChangeQst, true) then begin
                                Validate(Complete, false);
                                UndidCompleteStatus := true;
                            end else
                                Status := xRec.Status;
                    end;
                    Modify();

                    ATOLink.CheckIfAssembleToOrderLinkExist(Rec);
                    CheckIfTimeSheetLineLinkExist();

                    ContratoPlanningLine.SetCurrentKey("Job No.");
                    ContratoPlanningLine.SetRange("Job No.", "No.");
                    if ContratoPlanningLine.FindSet() then begin
                        ShouldDeleteReservationEntries := CheckReservationEntries();
                        repeat
                            if ShouldDeleteReservationEntries then
                                ContratoPlanningLineReserve.DeleteLineInternal(ContratoPlanningLine, false);
                            ATOLink.MakeAsmOrderLinkedToJobPlanningOrderLine(ContratoPlanningLine);
                            ContratoPlanningLine.Validate(Status, Status);
                            ContratoPlanningLine.Modify();
                        until ContratoPlanningLine.Next() = 0;
                        PerformAutoReserve(ContratoPlanningLine);
                        if UndidCompleteStatus then
                            ContratoPlanningLine.CreateWarehouseRequest();
                    end;
                    //ContratoArchiveManagement.AutoArchiveJob(Rec);
                end;
            end;
        }
        field(20; "Person Responsible"; Code[20])
        {
            Caption = 'Person Responsible';
            TableRelation = Resource where(Type = const(Person));
        }
        field(21; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(22; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(23; "Contrato Posting Group"; Code[20])
        {
            Caption = 'Project Posting Group';
            TableRelation = "Contrato Posting Group";
        }
        field(24; Blocked; Enum "Contrato Blocked")
        {
            Caption = 'Blocked';
        }
        field(29; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(30; Comment; Boolean)
        {
            CalcFormula = exist("Comment Line" where("Table Name" = const(Contrato),
                                                      "No." = field("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
        }
        field(32; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(35; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Location Code" <> xRec."Location Code") then
                    MessageIfContratoTaskExist(FieldCaption("Location Code"));

                SetDefaultBin();
            end;
        }
        field(36; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Bin Code" <> xRec."Bin Code") then
                    MessageIfContratoTaskExist(FieldCaption("Bin Code"));
            end;
        }
        field(41; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(49; "Scheduled Res. Qty."; Decimal)
        {
            CalcFormula = sum("Contrato Planning Line"."Quantity (Base)" where("Job No." = field("No."),
                                                                           "Schedule Line" = const(true),
                                                                           Type = const(Resource),
                                                                           "No." = field("Resource Filter"),
                                                                           "Planning Date" = field("Planning Date Filter")));
            Caption = 'Scheduled Res. Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Resource Filter"; Code[20])
        {
            Caption = 'Resource Filter';
            FieldClass = FlowFilter;
            TableRelation = Resource;
        }
        field(51; "Posting Date Filter"; Date)
        {
            Caption = 'Posting Date Filter';
            FieldClass = FlowFilter;
        }
        field(55; "Resource Gr. Filter"; Code[20])
        {
            Caption = 'Resource Gr. Filter';
            FieldClass = FlowFilter;
            TableRelation = "Resource Group";
        }
        field(56; "Scheduled Res. Gr. Qty."; Decimal)
        {
            CalcFormula = sum("Contrato Planning Line"."Quantity (Base)" where("Job No." = field("No."),
                                                                           "Schedule Line" = const(true),
                                                                           Type = const(Resource),
                                                                           "Resource Group No." = field("Resource Gr. Filter"),
                                                                           "Planning Date" = field("Planning Date Filter")));
            Caption = 'Scheduled Res. Gr. Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(57; Picture; BLOB)
        {
            Caption = 'Picture';
            ObsoleteReason = 'Replaced by Image field';
            ObsoleteState = Removed;
            SubType = Bitmap;
            ObsoleteTag = '18.0';
        }
        field(58; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Customer: Record Customer;
            begin
                if "Bill-to Customer No." <> '' then
                    Customer.Get("Bill-to Customer No.");

                if Customer.SelectCustomer(Customer) then begin
                    xRec := Rec;
                    "Bill-to Name" := Customer.Name;
                    Validate("Bill-to Customer No.", Customer."No.");
                end;
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if ShouldSearchForCustomerByName("Bill-to Customer No.") then
                    Validate("Bill-to Customer No.", Customer.GetCustNo("Bill-to Name"));
            end;
        }
        field(59; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
        }
        field(60; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
        }
        field(61; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            TableRelation = if ("Bill-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Bill-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Bill-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBillToCity(Rec, PostCode, CurrFieldNo, IsHandled);
                if not IsHandled then
                    PostCode.ValidateCity(
                        "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code",
                        (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(63; "Bill-to County"; Text[30])
        {
            CaptionClass = '5,3,' + "Bill-to Country/Region Code";
            Caption = 'Bill-to County';
        }
        field(64; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            TableRelation = if ("Bill-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Bill-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Bill-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBillToPostCode(Rec, PostCode, CurrFieldNo, IsHandled);
                if not IsHandled then
                    PostCode.ValidatePostCode(
                        "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code",
                        (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(66; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(67; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            Editable = true;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
#pragma warning disable AA0139
                PostCode.CheckClearPostCodeCityCounty(
                  "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code", xRec."Bill-to Country/Region Code");
#pragma warning restore AA0139
            end;
        }
        field(68; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
        }
        field(80; "Task Billing Method"; Enum "Task Billing Method")
        {
            Caption = 'Task Billing Method';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ContratoTask: Record "Contrato Task";
                RecRef: RecordRef;
                FldRef: FieldRef;
            begin
                ContratoTask.SetRange("Job No.", "No.");
                if ContratoTask.IsEmpty() then
                    exit;

                if ("Task Billing Method" = "Task Billing Method"::"One customer") and
                    (xRec."Task Billing Method" = XRec."Task Billing Method"::"Multiple customers") then begin
                    RecRef.GetTable(Rec);
                    FldRef := RecRef.Field(Rec.FieldNo("Task Billing Method"));
                    Error(UpdateBillingMethodErr, FldRef.GetEnumValueCaption(Rec."Task Billing Method".AsInteger() + 1), FieldCaption("Task Billing Method"), TableCaption());
                end;

                if "Task Billing Method" = "Task Billing Method"::"Multiple customers" then
                    if not Confirm(UpdateBillingMethodQst, true) then
                        Error('');

                InitCustomerOnContratoTasks();
            end;
        }
        field(117; Reserve; Enum "Reserve Method")
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Reserve';
        }
        field(140; Image; Media)
        {
            Caption = 'Image';
        }
        field(1000; "WIP Method"; Code[20])
        {
            Caption = 'WIP Method';
            TableRelation = "Contrato WIP Method".Code where(Valid = const(true));

            trigger OnValidate()
            var
                ContratoTask: Record "Contrato Task";
                ContratoWIPMethod: Record "Contrato WIP Method";
                ConfirmManagement: Codeunit "Confirm Management";
                NewWIPMethod: Code[20];
            begin
                if "WIP Posting Method" = "WIP Posting Method"::"Per Job Ledger Entry" then begin
                    ContratoWIPMethod.Get("WIP Method");
                    if not ContratoWIPMethod."WIP Cost" then
                        Error(WIPPostMethodErr, FieldCaption("WIP Posting Method"), FieldCaption("WIP Method"), ContratoWIPMethod.FieldCaption("WIP Cost"));
                    if not ContratoWIPMethod."WIP Sales" then
                        Error(WIPPostMethodErr, FieldCaption("WIP Posting Method"), FieldCaption("WIP Method"), ContratoWIPMethod.FieldCaption("WIP Sales"));
                end;

                ContratoTask.SetRange("Job No.", "No.");
                ContratoTask.SetRange("WIP-Total", ContratoTask."WIP-Total"::Total);
                if ContratoTask.FindFirst() then
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(WIPMethodQst, ContratoTask.FieldCaption("WIP Method"), ContratoTask.TableCaption(), ContratoTask."WIP-Total"), true) then begin
                        ContratoTask.ModifyAll("WIP Method", "WIP Method", true);
                        // An additional FIND call requires since ContratoTask.MODIFYALL changes the Job's information
                        NewWIPMethod := "WIP Method";
                        Find();
                        "WIP Method" := NewWIPMethod;
                    end;
            end;
        }
        field(1001; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateCurrencyCode(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if "Currency Code" <> xRec."Currency Code" then
                    if not ContratoLedgEntryExist() then begin
                        CurrencyUpdatePlanningLines();
                        CurrencyUpdatePurchLines();
                    end else
                        Error(AssociatedEntriesExistErr, FieldCaption("Currency Code"), TableCaption);
                if "Currency Code" <> '' then begin
                    Validate("Invoice Currency Code", '');
                    ClearInvCurrencyCodeOnContratoTasks();
                end;
            end;
        }
        field(1002; "Bill-to Contact No."; Code[20])
        {
            AccessByPermission = TableData Contact = R;
            Caption = 'Bill-to Contact No.';

            trigger OnLookup()
            begin
                BilltoContactLookup();
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBillToContactNo(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if ("Bill-to Contact No." <> xRec."Bill-to Contact No.") and
                   (xRec."Bill-to Contact No." <> '')
                then
                    if ("Bill-to Contact No." = '') and ("Bill-to Customer No." = '') then begin
                        Init();
                        "No. Series" := xRec."No. Series";
                        Validate(Description, xRec.Description);
                    end;

                if ("Bill-to Customer No." <> '') and ("Bill-to Contact No." <> '') then begin
                    Cont.Get("Bill-to Contact No.");
                    if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "Bill-to Customer No.") then
                        if ContBusinessRelation."Contact No." <> Cont."Company No." then
                            Error(ContactBusRelDiffCompErr, Cont."No.", Cont.Name, "Bill-to Customer No.");
                end;
                UpdateBillToCust("Bill-to Contact No.");
            end;
        }
        field(1003; "Bill-to Contact"; Text[100])
        {
            Caption = 'Bill-to Contact';
        }
        field(1004; "Planning Date Filter"; Date)
        {
            Caption = 'Planning Date Filter';
            FieldClass = FlowFilter;
        }
        field(1005; "Total WIP Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - sum("Contrato WIP Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                         "Job Complete" = const(false),
                                                                         Type = filter("Accrued Costs" | "Applied Costs" | "Recognized Costs")));
            Caption = 'Total WIP Cost Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1006; "Total WIP Cost G/L Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - sum("Job WIP G/L Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                             Reversed = const(false),
                                                                             "Job Complete" = const(false),
                                                                             Type = filter("Accrued Costs" | "Applied Costs" | "Recognized Costs")));
            Caption = 'Total WIP Cost G/L Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1007; "WIP Entries Exist"; Boolean)
        {
            CalcFormula = exist("Contrato WIP Entry" where("Job No." = field("No.")));
            Caption = 'WIP Entries Exist';
            FieldClass = FlowField;
        }
        field(1008; "WIP Posting Date"; Date)
        {
            Caption = 'WIP Posting Date';
            Editable = false;
        }
        field(1009; "WIP G/L Posting Date"; Date)
        {
            CalcFormula = min("Job WIP G/L Entry"."WIP Posting Date" where(Reversed = const(false),
                                                                            "Job No." = field("No.")));
            Caption = 'WIP G/L Posting Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1011; "Invoice Currency Code"; Code[10])
        {
            Caption = 'Invoice Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if ("Invoice Currency Code" <> xRec."Invoice Currency Code") and ("Task Billing Method" = "Task Billing Method"::"Multiple customers")
                    and ("Invoice Currency Code" <> '') then
                    MessageIfContratoTaskExist(FieldCaption("Invoice Currency Code"));

                if "Invoice Currency Code" <> '' then
                    Validate("Currency Code", '');
            end;
        }
        field(1012; "Exch. Calculation (Cost)"; Option)
        {
            Caption = 'Exch. Calculation (Cost)';
            OptionCaption = 'Fixed FCY,Fixed LCY';
            OptionMembers = "Fixed FCY","Fixed LCY";
        }
        field(1013; "Exch. Calculation (Price)"; Option)
        {
            Caption = 'Exch. Calculation (Price)';
            OptionCaption = 'Fixed FCY,Fixed LCY';
            OptionMembers = "Fixed FCY","Fixed LCY";
        }
        field(1014; "Allow Schedule/Contract Lines"; Boolean)
        {
            Caption = 'Allow Budget/Billable Lines';
        }
        field(1015; Complete; Boolean)
        {
            Caption = 'Complete';

            trigger OnValidate()
            begin
                if Complete <> xRec.Complete then
                    ChangeContratoCompletionStatus();
            end;
        }
        field(1017; "Recog. Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - sum("Contrato WIP Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                         Type = filter("Recognized Sales")));
            Caption = 'Recog. Sales Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1018; "Recog. Sales G/L Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - sum("Job WIP G/L Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                             Reversed = const(false),
                                                                             Type = filter("Recognized Sales")));
            Caption = 'Recog. Sales G/L Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1019; "Recog. Costs Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Contrato WIP Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                        Type = filter("Recognized Costs")));
            Caption = 'Recog. Costs Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Recog. Costs G/L Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Job WIP G/L Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                            Reversed = const(false),
                                                                            Type = filter("Recognized Costs")));
            Caption = 'Recog. Costs G/L Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1021; "Total WIP Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Contrato WIP Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                        "Job Complete" = const(false),
                                                                        Type = filter("Accrued Sales" | "Applied Sales" | "Recognized Sales")));
            Caption = 'Total WIP Sales Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1022; "Total WIP Sales G/L Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Job WIP G/L Entry"."WIP Entry Amount" where("Job No." = field("No."),
                                                                            Reversed = const(false),
                                                                            "Job Complete" = const(false),
                                                                            Type = filter("Accrued Sales" | "Applied Sales" | "Recognized Sales")));
            Caption = 'Total WIP Sales G/L Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1023; "WIP Completion Calculated"; Boolean)
        {
            CalcFormula = exist("Contrato WIP Entry" where("Job No." = field("No."),
                                                       "Job Complete" = const(true)));
            Caption = 'WIP Completion Calculated';
            FieldClass = FlowField;
        }
        field(1024; "Next Invoice Date"; Date)
        {
            CalcFormula = min("Contrato Planning Line"."Planning Date" where("Job No." = field("No."),
                                                                         "Contract Line" = const(true),
                                                                         "Qty. to Invoice" = filter(<> 0)));
            Caption = 'Next Invoice Date';
            FieldClass = FlowField;
        }
        field(1025; "Apply Usage Link"; Boolean)
        {
            Caption = 'Apply Usage Link';

            trigger OnValidate()
            var
                ContratoPlanningLine: Record "Contrato Planning Line";
                ContratoLedgerEntry: Record "Contrato Ledger Entry";
                ContratoUsageLink: Record "Contrato Usage Link";
                NewApplyUsageLink: Boolean;
            begin
                if "Apply Usage Link" then begin
                    ContratoLedgerEntry.SetCurrentKey("Job No.");
                    ContratoLedgerEntry.SetRange("Job No.", "No.");
                    ContratoLedgerEntry.SetRange("Entry Type", ContratoLedgerEntry."Entry Type"::Usage);
                    if ContratoLedgerEntry.FindFirst() then begin
                        ContratoUsageLink.SetRange("Entry No.", ContratoLedgerEntry."Entry No.");
                        if ContratoUsageLink.IsEmpty() then
                            Error(ApplyUsageLinkErr, TableCaption);
                    end;

                    ContratoPlanningLine.SetCurrentKey("Job No.");
                    ContratoPlanningLine.SetRange("Job No.", "No.");
                    ContratoPlanningLine.SetRange("Schedule Line", true);
                    if ContratoPlanningLine.FindSet() then begin
                        repeat
                            ContratoPlanningLine.Validate("Usage Link", true);
                            if ContratoPlanningLine."Planning Date" = 0D then
                                ContratoPlanningLine.Validate("Planning Date", WorkDate());
                            ContratoPlanningLine.Modify(true);
                        until ContratoPlanningLine.Next() = 0;

                        NewApplyUsageLink := "Apply Usage Link";
                        RefreshModifiedRec();
                        "Apply Usage Link" := NewApplyUsageLink;
                    end;
                end;
            end;
        }
        field(1026; "WIP Warnings"; Boolean)
        {
            CalcFormula = exist("Job WIP Warning" where("Job No." = field("No.")));
            Caption = 'WIP Warnings';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1027; "WIP Posting Method"; Option)
        {
            Caption = 'WIP Posting Method';
            OptionCaption = 'Per Project,Per Project Ledger Entry';
            OptionMembers = "Per Job","Per Job Ledger Entry";

            // trigger OnValidate()
            // var
            //     ContratoLedgerEntry: Record "Contrato Ledger Entry";
            //     ContratoWIPEntry: Record "Contrato WIP Entry";
            //     ContratoWIPMethod: Record "Job WIP Method";
            // begin
            //     if xRec."WIP Posting Method" = "WIP Posting Method"::"Per Job Ledger Entry" then begin
            //         ContratoLedgerEntry.SetRange("Job No.", "No.");
            //         ContratoLedgerEntry.SetFilter("Amt. Posted to G/L", '<>%1', 0);
            //         if not ContratoLedgerEntry.IsEmpty() then
            //             Error(WIPAlreadyPostedErr, FieldCaption("WIP Posting Method"), xRec."WIP Posting Method");
            //     end;

            //     ContratoWIPEntry.SetRange("Job No.", "No.");
            //     if not ContratoWIPEntry.IsEmpty() then
            //         Error(WIPAlreadyAssociatedErr, FieldCaption("WIP Posting Method"));

            //     if "WIP Posting Method" = "WIP Posting Method"::"Per Job Ledger Entry" then begin
            //         ContratoWIPMethod.Get("WIP Method");
            //         if not ContratoWIPMethod."WIP Cost" then
            //             Error(WIPPostMethodErr, FieldCaption("WIP Posting Method"), FieldCaption("WIP Method"), ContratoWIPMethod.FieldCaption("WIP Cost"));
            //         if not ContratoWIPMethod."WIP Sales" then
            //             Error(WIPPostMethodErr, FieldCaption("WIP Posting Method"), FieldCaption("WIP Method"), ContratoWIPMethod.FieldCaption("WIP Sales"));
            //     end;
            // end;
        }
        // field(1028; "Applied Costs G/L Amount"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = - sum("Job WIP G/L Entry"."WIP Entry Amount" where("Job No." = field("No."),
        //                                                                      Reverse = const(false),
        //                                                                      "Job Complete" = const(false),
        //                                                                      Type = filter("Applied Costs")));
        //     Caption = 'Applied Costs G/L Amount';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(1029; "Applied Sales G/L Amount"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = - sum("Job WIP G/L Entry"."WIP Entry Amount" where("Job No." = field("No."),
        //                                                                      Reverse = const(false),
        //                                                                      "Job Complete" = const(false),
        //                                                                      Type = filter("Applied Sales")));
        //     Caption = 'Applied Sales G/L Amount';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        field(1030; "Calc. Recog. Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Contrato Task"."Recognized Sales Amount" where("Job No." = field("No.")));
            Caption = 'Calc. Recog. Sales Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1031; "Calc. Recog. Costs Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Contrato Task"."Recognized Costs Amount" where("Job No." = field("No.")));
            Caption = 'Calc. Recog. Costs Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1032; "Calc. Recog. Sales G/L Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Contrato Task"."Recognized Sales G/L Amount" where("Job No." = field("No.")));
            Caption = 'Calc. Recog. Sales G/L Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1033; "Calc. Recog. Costs G/L Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Contrato Task"."Recognized Costs G/L Amount" where("Job No." = field("No.")));
            Caption = 'Calc. Recog. Costs G/L Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1034; "WIP Completion Posted"; Boolean)
        {
            CalcFormula = exist("Job WIP G/L Entry" where("Job No." = field("No."),
                                                           "Job Complete" = const(true)));
            Caption = 'WIP Completion Posted';
            FieldClass = FlowField;
        }
        field(1035; "Over Budget"; Boolean)
        {
            Caption = 'Over Budget';
        }
        field(1036; "Project Manager"; Code[50])
        {
            Caption = 'Project Manager';
            TableRelation = "User Setup";
        }
        field(2000; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                SellToCustomerNoUpdated(Rec, xRec);
            end;
        }
        field(2001; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                CustomerName: Text;
            begin
                CustomerName := "Sell-to Customer Name";
                LookupSellToCustomerName(CustomerName);
                "Sell-to Customer Name" := CopyStr(CustomerName, 1, MaxStrLen("Sell-to Customer Name"));
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
                LookupStateManager: Codeunit "Lookup State Manager";
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateSellToCustomerName(Rec, Customer, IsHandled);
                if IsHandled then begin
                    if LookupStateManager.IsRecordSaved() then
                        LookupStateManager.ClearSavedRecord();
                    exit;
                end;

                if LookupStateManager.IsRecordSaved() then begin
                    Customer := LookupStateManager.GetSavedRecord();
                    if Customer."No." <> '' then begin
                        LookupStateManager.ClearSavedRecord();
                        Validate("Sell-to Customer No.", Customer."No.");

                        exit;
                    end;
                end;

                if ShouldSearchForCustomerByName("Sell-to Customer No.") then
                    Validate("Sell-to Customer No.", Customer.GetCustNo("Sell-to Customer Name"));
            end;
        }
        field(2002; "Sell-to Customer Name 2"; Text[50])
        {
            Caption = 'Sell-to Customer Name 2';
        }
        field(2003; "Sell-to Address"; Text[100])
        {
            Caption = 'Sell-to Address';
        }
        field(2004; "Sell-to Address 2"; Text[50])
        {
            Caption = 'Sell-to Address 2';
        }
        field(2005; "Sell-to City"; Text[30])
        {
            Caption = 'Sell-to City';
            TableRelation = if ("Sell-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Sell-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Sell-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Sell-to City", "Sell-to Post Code", "Sell-to County", "Sell-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateSellToCity(Rec, PostCode, CurrFieldNo, IsHandled);
                if not IsHandled then
                    PostCode.ValidateCity(
                        "Sell-to City", "Sell-to Post Code", "Sell-to County", "Sell-to Country/Region Code",
                        (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(2006; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';
        }
        field(2007; "Sell-to Post Code"; Code[20])
        {
            Caption = 'Sell-to Post Code';
            TableRelation = if ("Sell-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Sell-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Sell-to Country/Region Code"));
            ValidateTableRelation = false;
        }
        field(2008; "Sell-to County"; Text[30])
        {
            CaptionClass = '5,2,' + "Sell-to Country/Region Code";
            Caption = 'Sell-to County';
        }
        field(2009; "Sell-to Country/Region Code"; Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(2010; "Sell-to Phone No."; Text[30])
        {
            Caption = 'Sell-to Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(2011; "Sell-to E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Sell-to E-Mail" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("Sell-to E-Mail");
            end;
        }
        field(2012; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            begin
                SelltoContactLookup();
            end;

            trigger OnValidate()
            var
                Contact: Record Contact;
                ContactBusinessRelation: Record "Contact Business Relation";
            begin
                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") and
                   (xRec."Sell-to Contact No." <> '')
                then
                    if ("Sell-to Contact No." = '') and ("Sell-to Customer No." = '') then begin
                        Init();
                        "No. Series" := xRec."No. Series";
                        Validate(Description, xRec.Description);
                    end;

                if ("Sell-to Customer No." <> '') and ("Sell-to Contact No." <> '') then begin
                    Contact.SetLoadFields(Name, "Company No.");
                    Contact.Get("Sell-to Contact No.");
                    if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, "Sell-to Customer No.") then
                        if ContactBusinessRelation."Contact No." <> Contact."Company No." then
                            Error(ContactBusRelDiffCompErr, Contact."No.", Contact.Name, "Sell-to Customer No.");
                end;
                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") then
                    UpdateSellToCust("Sell-to Contact No.");

                UpdateShipToContact();
            end;
        }
        field(3000; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Sell-to Customer No."));

            trigger OnValidate()
            begin
                if ("Ship-to Code" <> xRec."Ship-to Code") and ("Task Billing Method" = "Task Billing Method"::"Multiple customers") then
                    MessageIfContratoTaskExist(FieldCaption("Ship-to Code"));

                ShipToCodeValidate();
            end;
        }
        field(3001; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
        }
        field(3002; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
        }
        field(3003; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
        }
        field(3004; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(3005; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            TableRelation = if ("Ship-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Ship-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Ship-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateShipToCity(Rec, PostCode, CurrFieldNo, IsHandled);
                if not IsHandled then
                    PostCode.ValidateCity(
                        "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code",
                        (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(3006; "Ship-to Contact"; Text[100])
        {
            Caption = 'Ship-to Contact';
        }
        field(3007; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            TableRelation = if ("Ship-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Ship-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Ship-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                    "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(3008; "Ship-to County"; Text[30])
        {
            CaptionClass = '5,4,' + "Ship-to Country/Region Code";
            Caption = 'Ship-to County';
        }
        field(3009; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(3997; "No. of Archived Versions"; Integer)
        {
            CalcFormula = max("Job Archive"."Version No." where("No." = field("No.")));
            Caption = 'No. of Archived Versions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4000; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';

            trigger OnValidate()
            begin
                if ("External Document No." <> xRec."External Document No.") and ("Task Billing Method" = "Task Billing Method"::"Multiple customers") then
                    MessageIfContratoTaskExist(FieldCaption("External Document No."));
            end;
        }
        field(4001; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                if ("Payment Method Code" <> xRec."Payment Method Code") and ("Task Billing Method" = "Task Billing Method"::"Multiple customers") then
                    MessageIfContratoTaskExist(FieldCaption("Payment Method Code"));
            end;
        }
        field(4002; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";

            trigger OnValidate()
            begin
                if ("Payment Terms Code" <> xRec."Payment Terms Code") and ("Task Billing Method" = "Task Billing Method"::"Multiple customers") then
                    MessageIfContratoTaskExist(FieldCaption("Payment Terms Code"));
            end;
        }
        field(4003; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';

            trigger OnValidate()
            begin
                if ("Your Reference" <> xRec."Your Reference") and ("Task Billing Method" = "Task Billing Method"::"Multiple customers") then
                    MessageIfContratoTaskExist(FieldCaption("Your Reference"));
            end;
        }
        field(7000; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';

            trigger OnValidate()
            var
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
                PriceType: Enum "Price Type";
            begin
                if "Price Calculation Method" <> "Price Calculation Method"::" " then
                    PriceCalculationMgt.VerifyMethodImplemented("Price Calculation Method", PriceType::Sale);
            end;
        }
        field(7001; "Cost Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Cost Calculation Method';

            trigger OnValidate()
            var
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
                PriceType: Enum "Price Type";
            begin
                if "Cost Calculation Method" <> "Cost Calculation Method"::" " then
                    PriceCalculationMgt.VerifyMethodImplemented("Cost Calculation Method", PriceType::Purchase);
            end;
        }
        field(7300; "Completely Picked"; Boolean)
        {
            CalcFormula = min("Contrato Planning Line"."Completely Picked" where("Job No." = field("No.")));
            Caption = 'Completely Picked';
            FieldClass = FlowField;
        }
        field(8000; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'This functionality will be replaced by the systemID field';
            ObsoleteTag = '22.0';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Search Description")
        {
        }
        key(Key3; "Bill-to Customer No.")
        {
        }
        key(Key4; Description)
        {
        }
        key(Key5; Status)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Bill-to Customer No.", "Starting Date", Status)
        {
        }
        fieldgroup(Brick; "No.", Description, "Bill-to Customer No.", "Starting Date", Status, Image)
        {
        }
    }

    trigger OnDelete()
    var
        WhseRequest: Record "Warehouse Request";
    begin
        ConfirmDeletion();

        //MoveEntries.MoveJobEntries(Rec);

        //ContratoArchiveManagement.AutoArchiveContrato(Rec);

        DeleteRelatedContratoTasks();

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::Job);
        CommentLine.SetRange("No.", "No.");
        CommentLine.DeleteAll();

        DimMgt.DeleteDefaultDim(DATABASE::Job, "No.");

        if "Project Manager" <> '' then
            RemoveFromMyContratos();

        // Delete all warehouse requests and warehouse pick requests associated with the Job
        WhseRequest.DeleteRequest(Database::Contrato, 0, "No.");
        DeleteWhsePickRelation();
    end;

    trigger OnInsert()
    begin
        ContratosSetup.Get();

        InitContratoNo();
        InitBillToCustomerNo();

        if not "Apply Usage Link" then
            Validate("Apply Usage Link", ContratosSetup."Apply Usage Link by Default");
        if not "Allow Schedule/Contract Lines" then
            Validate("Allow Schedule/Contract Lines", ContratosSetup."Allow Sched/Contract Lines Def");
        // if "WIP Method" = '' then
        //     Validate("WIP Method", ContratosSetup."Default WIP Method");
        InitDefaultContratoPostingGroup();
        Validate("WIP Posting Method", ContratosSetup."Default WIP Posting Method");
        "Task Billing Method" := ContratosSetup."Default Task Billing Method";

        InitGlobalDimFromDefalutDim();
        InitWIPFields();

        "Creation Date" := Today;
        "Last Date Modified" := "Creation Date";

        if ("Project Manager" <> '') and (Status = Status::Open) then
            AddToMyContratos("Project Manager");

        OnAfterOnInsert(Rec, xRec);
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        CheckRemoveFromMyContratosFromModify();

        if ("Project Manager" <> '') and (xRec."Project Manager" <> "Project Manager") then
            if Status = Status::Open then
                AddToMyContratos("Project Manager");
    end;

    trigger OnRename()
    begin
        UpdateContratoNoInReservationEntries();
        DimMgt.RenameDefaultDim(DATABASE::Job, xRec."No.", "No.");
        CommentLine.RenameCommentLine(CommentLine."Table Name"::Job, xRec."No.", "No.");
        "Last Date Modified" := Today;
    end;

    var
        ContratosSetup: Record "Contratos Setup";
        PostCode: Record "Post Code";
        Job: Record Contrato;
        Cust: Record Customer;
        Cont: Record Contact;
        ContBusinessRelation: Record "Contact Business Relation";
        CommentLine: Record "Comment Line";
        Location: Record Location;
        MoveEntries: Codeunit MoveEntries;
        ContratoArchiveManagement: Codeunit "Job Archive Management";
        HideValidationDialog: Boolean;

        AssociatedEntriesExistErr: Label 'You cannot change %1 because one or more entries are associated with this %2.', Comment = '%1 = Name of field used in the error; %2 = The name of the Project table';
        StatusChangeQst: Label 'This will delete any unposted WIP entries for this project and allow you to reverse the completion postings for this project.\\Do you wish to continue?';
        ContactBusRelDiffCompErr: Label 'Contact %1 %2 is related to a different company than customer %3.', Comment = '%1 = The contact number; %2 = The contact''s name; %3 = The Bill-To Customer Number associated with this Job';
        ContactBusRelErr: Label 'Contact %1 %2 is not related to customer %3.', Comment = '%1 = The contact number; %2 = The contact''s name; %3 = The Bill-To Customer Number associated with this Job';
        ContactBusRelMissingErr: Label 'Contact %1 %2 is not related to a customer.', Comment = '%1 = The contact number; %2 = The contact''s name';
        TestBlockedErr: Label '%1 %2 must not be blocked with type %3.', Comment = '%1 = The Project table name; %2 = The Project number; %3 = The value of the Blocked field';
        ReverseCompletionEntriesMsg: Label 'You must run the %1 function to reverse the completion entries that have already been posted for this project.', Comment = '%1 = The name of the Project Post WIP to G/L report';
        CheckDateErr: Label '%1 must be equal to or earlier than %2.', Comment = '%1 = The project''s starting date; %2 = The project''s ending date';
        ApplyUsageLinkErr: Label 'A usage link cannot be enabled for the entire %1 because usage without the usage link already has been posted.', Comment = '%1 = The name of the Project table';
        WIPMethodQst: Label 'Do you want to set the %1 on every %2 of type %3?', Comment = '%1 = The WIP Method field name; %2 = The name of the Project Task table; %3 = The current project task''s WIP Total type';
        WIPAlreadyPostedErr: Label '%1 must be %2 because project WIP general ledger entries already were posted with this setting.', Comment = '%1 = The name of the WIP Posting Method field; %2 = The previous WIP Posting Method value of this project';
        WIPAlreadyAssociatedErr: Label '%1 cannot be modified because the project has associated project WIP entries.', Comment = '%1 = The name of the WIP Posting Method field';
        WIPPostMethodErr: Label 'The selected %1 requires the %2 to have %3 enabled.', Comment = '%1 = The name of the WIP Posting Method field; %2 = The name of the WIP Method field; %3 = The field caption represented by the value of this project''s WIP method';
        EndingDateChangedMsg: Label '%1 is set to %2.', Comment = '%1 = The name of the Ending Date field; %2 = This project''s Ending Date value';
        UpdateContratoTaskDimQst: Label 'You have changed a dimension.\\Do you want to update the lines?';
        RunWIPFunctionsQst: Label 'You must run the Project Calculate WIP function to create completion entries for this project. \Do you want to run this function now?';
        ReservEntriesItemTrackLinesDeleteQst: Label 'All reservation entries and item tracking lines for this project will be deleted. \Do you want to continue?';
        ReservEntriesItemTrackLinesExistErr: Label 'You cannot set the status to %1 because the project has reservations or item tracking lines on the project planning lines.', Comment = '%1=The project status name';
        AutoReserveNotPossibleMsg: Label 'Automatic reservation is not possible for one or more project planning lines. \Please reserve manually.';
        WhseCompletelyPickedErr: Label 'All of the items on the project planning lines are completely picked.';
        WhseNoItemsToPickErr: Label 'There are no items to pick on the project planning lines.';
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        SellToCustomerTxt: Label 'Sell-to Customer';
        BillToCustomerTxt: Label 'Bill-to Customer';
        StatusCompletedErr: Label 'You cannot select Project No.: %1 as it is already completed.', Comment = '%1= The Project No.';
        ConfirmEmptyEmailQst: Label 'Contact %1 has no email address specified. The value in the Email field on the project, %2, will be deleted. Do you want to continue?', Comment = '%1 - Contact No., %2 - Email';
        TasksNotUpdatedMsg: Label 'You have changed %1 on the project, but it has not been changed on the existing project tasks.', Comment = '%1 = a Field Caption like Location Code';
        UpdateTasksManuallyMsg: Label 'You must update the existing project tasks manually.';
        SplitMessageTxt: Label '%1\%2', Comment = 'Some message text 1.\Some message text 2.', Locked = true;
        UpdateBillingMethodQst: Label 'This change will make a difference to how project tasks are billed. This is irreversible. Do you want to continue?';
        UpdateBillingMethodErr: Label 'You cannot select %1 in %2, because one or more Project Tasks exist for this %3.', Comment = '%1 = Caption of the Task Billing Method field value; %2 = Caption of the Task Billing Method field; %3 = Caption of the Project table';
        UpdateCostPricesOnRelatedLinesQst: Label 'You have changed a customer. Prices and costs needs to be updated on a related lines.\\Do you want to update related lines?';
        ConfirmDeleteQst: Label 'The items have been picked. If you delete the Job, then the items will remain in the operation area until you put them away.\Related item tracking information that is defined during the pick will be deleted.\Are you sure that you want to delete the Job?';

    protected var
#if not CLEAN24
        [Obsolete('Variable NoSeriesMgt is obsolete and will be removed. Please refer to No. Series codeunit instead.', '24.0')]
        NoSeriesMgt: Codeunit NoSeriesManagement;
#endif
        NoSeries: Codeunit "No. Series";
        DimMgt: Codeunit DimensionManagement;
        SkipSellToContact: Boolean;

    procedure AssistEdit(OldContrato: Record Contrato) Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
#if not CLEAN24
        OnBeforeAssistEdit(Rec, OldContrato, Result, IsHandled, NoSeriesMgt);
#else
        OnBeforeAssistEdit(Rec, OldContrato, Result, IsHandled);
#endif
        if IsHandled then
            exit(Result);

        Job := Rec;
        ContratosSetup.Get();
        ContratosSetup.TestField("Contrato Nos.");
        if NoSeries.LookupRelatedNoSeries(ContratosSetup."Contrato Nos.", OldContrato."No. Series", Job."No. Series") then begin
            Job."No." := NoSeries.GetNextNo(Job."No. Series");
            Rec := Job;
            exit(true);
        end;
    end;

    procedure GetCostCalculationMethod() Method: Enum "Price Calculation Method";
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if "Cost Calculation Method" <> Method::" " then
            Method := "Cost Calculation Method"
        else begin
            PurchasesPayablesSetup.Get();
            Method := PurchasesPayablesSetup."Price Calculation Method";
        end;
    end;

    procedure GetPriceCalculationMethod() Method: Enum "Price Calculation Method";
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if "Price Calculation Method" <> Method::" " then
            Method := "Price Calculation Method"
        else begin
            Method := GetCustomerPriceGroupPriceCalcMethod();
            if Method = Method::" " then begin
                SalesReceivablesSetup.Get();
                Method := SalesReceivablesSetup."Price Calculation Method";
            end;
        end;
    end;

    local procedure GetCustomerPriceGroupPriceCalcMethod(): Enum "Price Calculation Method";
    var
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        if "Customer Price Group" <> '' then
            if CustomerPriceGroup.Get("Customer Price Group") then
                exit(CustomerPriceGroup."Price Calculation Method");
    end;

    local procedure CheckRemoveFromMyContratosFromModify()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckRemoveFromMyContratosFromModify(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if (("Project Manager" <> xRec."Project Manager") and (xRec."Project Manager" <> '')) or (Status <> Status::Open) then
            RemoveFromMyContratos();
    end;

    local procedure InitContratoNo()
    var
        Contrato2: Record Contrato;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitContratoNo(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "No." = '' then begin
            ContratosSetup.TestField("Contrato Nos.");
#if not CLEAN24
            NoSeriesMgt.RaiseObsoleteOnBeforeInitSeries(ContratosSetup."Contrato Nos.", xRec."No. Series", 0D, "No.", "No. Series", IsHandled);
            if not IsHandled then begin
#endif
                "No. Series" := ContratosSetup."Contrato Nos.";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
                Contrato2.ReadIsolation(IsolationLevel::ReadUncommitted);
                Contrato2.SetLoadFields("No.");
                while Contrato2.Get("No.") do
                    "No." := NoSeries.GetNextNo("No. Series");
#if not CLEAN24
                NoSeriesMgt.RaiseObsoleteOnAfterInitSeries("No. Series", ContratosSetup."Contrato Nos.", 0D, "No.");
            end;
#endif
        end;
    end;

    local procedure InitBillToCustomerNo()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitBillToCustomerNo(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if GetFilter("Bill-to Customer No.") <> '' then
            if GetRangeMin("Bill-to Customer No.") = GetRangeMax("Bill-to Customer No.") then begin
                Validate("Bill-to Customer No.", GetRangeMin("Bill-to Customer No."));
                if "Sell-to Customer No." = '' then
                    Validate("Sell-to Customer No.", "Bill-to Customer No.");
            end;
    end;

    local procedure AsPriceSource(var PriceSource: Record "Price Source")
    begin
        PriceSource.Init();
        PriceSource."Source Type" := PriceSource."Source Type"::Job;
        PriceSource."Source No." := "No.";
    end;

    procedure ShowPriceListLines(PriceType: Enum "Price Type"; AssetType: Enum "Price Asset Type";
                                                AmountType: Enum "Price Amount Type")
    var
        PriceAsset: Record "Price Asset";
        PriceSource: Record "Price Source";
        PriceUXManagement: Codeunit "Price UX Management";
    begin
        PriceAsset.InitAsset();
        PriceAsset.Validate("Asset Type", AssetType);
        AsPriceSource(PriceSource);
        PriceSource."Price Type" := PriceType;
        PriceUXManagement.ShowPriceListLines(PriceSource, PriceAsset, AmountType);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; ShortcutDimCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, IsHandled);
        if IsHandled then
            exit;

        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary then begin
            DimMgt.SaveDefaultDim(DATABASE::Contrato, "No.", FieldNumber, ShortcutDimCode);
            UpdateContratoTaskDimension(FieldNumber, ShortcutDimCode);
            Modify();
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure UpdateBillToContact(CustomerNo: Code[20])
    begin
        GetCustomerContact(CustomerNo, Rec."Bill-to Contact No.", Rec."Bill-to Contact");

        OnAfterUpdateBillToContact(Rec, xRec);
    end;

    protected procedure UpdateSellToContact(CustomerNo: Code[20])
    begin
        GetCustomerContact(CustomerNo, Rec."Sell-to Contact No.", Rec."Sell-to Contact");
    end;

    local procedure GetCustomerContact(CustomerNo: Code[20]; var ContactNo: Code[20]; var Contact: Text[100])
    var
        ContBusRel: Record "Contact Business Relation";
        Cust: Record Customer;
    begin
        if Cust.Get(CustomerNo) then begin
            if Cust."Primary Contact No." <> '' then
                ContactNo := Cust."Primary Contact No."
            else begin
                ContBusRel.Reset();
                ContBusRel.SetCurrentKey("Link to Table", "No.");
                ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SetRange("No.", CustomerNo);
                if ContBusRel.FindFirst() then
                    ContactNo := ContBusRel."Contact No.";
            end;
            Contact := Cust.Contact;
        end;
    end;

    procedure ContratoLedgEntryExist() Result: Boolean
    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
    begin
        Clear(ContratoLedgEntry);
        ContratoLedgEntry.SetCurrentKey("Job No.");
        ContratoLedgEntry.SetRange("Job No.", "No.");
        Result := not ContratoLedgEntry.IsEmpty();
        OnAfterContratoLedgEntryExist(ContratoLedgEntry, Result);
    end;

    procedure SalesContratoLedgEntryExist() Result: Boolean
    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
    begin
        ContratoLedgEntry.SetCurrentKey("Job No.");
        ContratoLedgEntry.SetRange("Job No.", "No.");
        ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Sale);
        Result := not ContratoLedgEntry.IsEmpty();
    end;

    procedure SalesLineExist() Result: Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if "No." = '' then
            exit(false);

        SalesLine.SetCurrentKey("Job No.");
        SalesLine.SetRange("Job No.", "No.");
        Result := not SalesLine.IsEmpty();
    end;

    procedure ContratoPlanningLineExist() Result: Boolean
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoPlanningLine.Init();
        ContratoPlanningLine.SetRange("Job No.", "No.");
        Result := not ContratoPlanningLine.IsEmpty();
        OnAfterContratoPlanningLineExist(ContratoPlanningLine, Result);
    end;

    procedure UpdateBillToCust(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Cust: Record Customer;
        Cont: Record Contact;
    begin
        if Cont.Get(ContactNo) then begin
            "Bill-to Contact No." := Cont."No.";
            if Cont.Type = Cont.Type::Person then
                "Bill-to Contact" := Cont.Name
            else
                if Cust.Get("Bill-to Customer No.") then
                    "Bill-to Contact" := Cust.Contact
                else
                    "Bill-to Contact" := '';
        end else begin
            "Bill-to Contact" := '';
            exit;
        end;

        OnUpdateBillToCustOnAfterAssignBillToContact(Rec, Cont);

        if ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."Company No.") then begin
            if "Bill-to Customer No." = '' then
                Validate("Bill-to Customer No.", ContBusinessRelation."No.")
            else
                CheckContactBillToCustomerBusRelation();
        end else
            ShowContactBillToCustomerBusRelationMissingError();
    end;

    local procedure CheckContactBillToCustomerBusRelation()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckContactBillToCustomerBusRelation(Rec, Cont, IsHandled);
        if IsHandled then
            exit;

        if "Bill-to Customer No." <> ContBusinessRelation."No." then
            Error(ContactBusRelErr, Cont."No.", Cont.Name, "Bill-to Customer No.");
    end;

    local procedure ShowContactBillToCustomerBusRelationMissingError()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowContactBillToCustomerBusRelationMissingError(Rec, Cont, IsHandled);
        if IsHandled then
            exit;

        Error(ContactBusRelMissingErr, Cont."No.", Cont.Name);
    end;

    procedure SelltoCustomerNoOnAfterValidate(var ContratoRec: Record "Contrato"; var xContratoRec: Record "Contrato")
    begin
        if ContratoRec.GetFilter("Sell-to Customer No.") = xContratoRec."Sell-to Customer No." then
            if ContratoRec."Sell-to Customer No." <> xContratoRec."Sell-to Customer No." then
                ContratoRec.SetRange("Sell-to Customer No.");
    end;

    procedure LookupSellToCustomerName(var CustomerName: Text): Boolean
    var
        Customer: Record Customer;
        LookupStateManager: Codeunit "Lookup State Manager";
        RecVariant: Variant;
        SearchCustomerName: Text;
    begin
        SearchCustomerName := CustomerName;
        Customer.SetFilter("Date Filter", GetFilter("Posting Date Filter"));
        if "Sell-to Customer No." <> '' then
            Customer.Get("Sell-to Customer No.");

        if Customer.SelectCustomer(Customer) then begin
            if Rec."Sell-to Customer Name" = Customer.Name then
                CustomerName := SearchCustomerName
            else
                CustomerName := Customer.Name;
            RecVariant := Customer;
            LookupStateManager.SaveRecord(RecVariant);
            exit(true);
        end;
    end;

    procedure InitWIPFields()
    begin
        "WIP Posting Date" := 0D;
        //"WIP G/L Posting Date" := 0D;
    end;

    local procedure InitGlobalDimFromDefalutDim()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitGlobalDimFromDefalutDim(Rec, IsHandled);
        if IsHandled then
            exit;

        DimMgt.UpdateDefaultDim(
            DATABASE::Contrato, "No.",
            "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    procedure TestBlocked()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestBlocked(Rec, IsHandled);
        if IsHandled then
            exit;

        // if Blocked = Blocked::" " then
        //     exit;
        // Error(TestBlockedErr, TableCaption(), "No.", Blocked);
    end;

    procedure CurrencyUpdatePlanningLines()
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCurrencyUpdatePlanningLines(Rec, IsHandled);
        if IsHandled then
            exit;

        ContratoPlanningLine.SetRange("Job No.", "No.");
        ContratoPlanningLine.SetAutoCalcFields("Qty. Transferred to Invoice");
        ContratoPlanningLine.LockTable();
        if ContratoPlanningLine.Find('-') then
            repeat
                OnCurrencyUpdatePlanningLinesOnBeforeUpdateContratoPlanningLine(Job, ContratoPlanningLine);
                if ContratoPlanningLine."Qty. Transferred to Invoice" <> 0 then
                    Error(AssociatedEntriesExistErr, FieldCaption("Currency Code"), TableCaption);
                ContratoPlanningLine.Validate("Currency Code", "Currency Code");
                ContratoPlanningLine.Validate("Currency Date");
                ContratoPlanningLine.Modify();
            until ContratoPlanningLine.Next() = 0;
    end;

    procedure TestStatusCompleted()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestStatusCompleted(Rec, IsHandled);
        if IsHandled then
            exit;

        if not (Status = Status::Completed) then
            exit;
        Error(StatusCompletedErr, "No.");
    end;

    local procedure CurrencyUpdatePurchLines()
    var
        PurchLine: Record "Purchase Line";
    begin
        Modify();
        PurchLine.SetRange("Job No.", "No.");
        if PurchLine.FindSet() then
            repeat
                PurchLine.Validate("Job Currency Code", "Currency Code");
                PurchLine.Validate("Job Task No.");
                PurchLine.Modify();
            until PurchLine.Next() = 0;
    end;

    local procedure ChangeContratoCompletionStatus()
    var
        WhseRequest: Record "Warehouse Request";
        ContratoCalcWIP: Codeunit "Job Calculate WIP";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeChangeContratoCompletionStatus(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if Complete then begin
            Validate("Ending Date", CalcEndingDate());
            Message(EndingDateChangedMsg, FieldCaption("Ending Date"), "Ending Date");

            WhseRequest.DeleteRequest(Database::Contrato, 0, "No.");
            DeleteWhsePickRelation();
        end else begin
            ContratoCalcWIP.ReOpenJob("No.");
            "WIP Posting Date" := 0D;
            Message(ReverseCompletionEntriesMsg, GetReportCaption(REPORT::"Job Post WIP to G/L"));
        end;

        OnAfterChangeContratoCompletionStatus(Rec, xRec);
    end;

    procedure CreateInvtPutAwayPick()
    var
        WhseRequest: Record "Warehouse Request";
    begin
        TestField(Status, Status::Open);

        WhseRequest.Reset();
        WhseRequest.SetCurrentKey("Source Document", "Source No.");
        WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Job Usage");
        WhseRequest.SetRange("Source Type", Database::Contrato);
        WhseRequest.SetRange("Source No.", "No.");
        REPORT.RunModal(REPORT::"Create Invt Put-away/Pick/Mvmt", true, false, WhseRequest);
    end;

    procedure DisplayMap()
    var
        OnlineMapManagement: Codeunit "Online Map Management";
    begin
        OnlineMapManagement.MakeSelectionIfMapEnabled(Database::Contrato, GetPosition());
    end;

    procedure GetQuantityAvailable(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; InEntryType: Option Usage,Sale,Both; Direction: Option Positive,Negative,Both): Decimal
    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
    begin
        Clear(ContratoLedgEntry);
        ContratoLedgEntry.SetCurrentKey("Job No.", "Entry Type", Type, "No.");
        ContratoLedgEntry.SetRange("Job No.", "No.");
        if not (InEntryType = InEntryType::Both) then
            ContratoLedgEntry.SetRange("Entry Type", InEntryType);
        ContratoLedgEntry.SetRange(Type, ContratoLedgEntry.Type::Item);
        ContratoLedgEntry.SetRange("No.", ItemNo);
        case Direction of
            Direction::Both:
                begin
                    ContratoLedgEntry.SetRange("Location Code", LocationCode);
                    ContratoLedgEntry.SetRange("Variant Code", VariantCode);
                end;
            Direction::Positive:
                ContratoLedgEntry.SetFilter("Quantity (Base)", '>0');
            Direction::Negative:
                ContratoLedgEntry.SetFilter("Quantity (Base)", '<0');
        end;
        //OnGetQuantityAvailableOnAfterSetFiltersOnContratoLedgerEntry(ItemNo, LocationCode, VariantCode, InEntryType, Direction, ContratoLedgEntry);
        ContratoLedgEntry.CalcSums("Quantity (Base)");
        exit(ContratoLedgEntry."Quantity (Base)");
    end;

    local procedure CheckDate()
    begin
        if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
            Error(CheckDateErr, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
    end;

    procedure CalcAccWIPCostsAmount(): Decimal
    begin
        //exit("Total WIP Cost Amount" + "Applied Costs G/L Amount");
    end;

    procedure CalcAccWIPSalesAmount(): Decimal
    begin
        //exit("Total WIP Sales Amount" - "Applied Sales G/L Amount");
    end;

    procedure CalcRecognizedProfitAmount() Result: Decimal
    begin
        CalcFields("Calc. Recog. Sales Amount", "Calc. Recog. Costs Amount");
        Result := "Calc. Recog. Sales Amount" - "Calc. Recog. Costs Amount";
        OnAfterCalcRecognizedProfitAmount(Result);
    end;

    procedure CalcRecognizedProfitPercentage(): Decimal
    begin
        if "Calc. Recog. Sales Amount" <> 0 then
            exit((CalcRecognizedProfitAmount() / "Calc. Recog. Sales Amount") * 100);
        exit(0);
    end;

    procedure CalcRecognizedProfitGLAmount(): Decimal
    begin
        CalcFields("Calc. Recog. Sales G/L Amount", "Calc. Recog. Costs G/L Amount");
        exit("Calc. Recog. Sales G/L Amount" - "Calc. Recog. Costs G/L Amount");
    end;

    procedure CalcRecognProfitGLPercentage(): Decimal
    begin
        if "Calc. Recog. Sales G/L Amount" <> 0 then
            exit((CalcRecognizedProfitGLAmount() / "Calc. Recog. Sales G/L Amount") * 100);
        exit(0);
    end;

    procedure CopyDefaultDimensionsFromCustomer()
    var
        CustDefaultDimension: Record "Default Dimension";
        ContratoDefaultDimension: Record "Default Dimension";
        Contrato2: Record Contrato;
        IsHandled: Boolean;
        ContratoExistsInDB: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyDefaultDimensionsFromCustomer(Rec, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        Contrato2.SetRange("No.", Rec."No.");
        ContratoExistsInDB := not Contrato2.IsEmpty();
        if ContratoExistsInDB then
            Rec.Modify();

        DimMgt.SetSkipUpdateDimensions(Rec."Task Billing Method" = Rec."Task Billing Method"::"Multiple customers");

        ContratoDefaultDimension.SetRange("Table ID", DATABASE::Job);
        ContratoDefaultDimension.SetRange("No.", "No.");
        if ContratoDefaultDimension.FindSet() then
            repeat
                DimMgt.DefaultDimOnDelete(ContratoDefaultDimension);
                DimMgt.SetSkipChangeDimensionsQst(true);
                ContratoDefaultDimension.Delete();
            until ContratoDefaultDimension.Next() = 0;
        if ContratoExistsInDB then
            Rec.Get(Rec."No.");

        CustDefaultDimension.SetRange("Table ID", DATABASE::Customer);
        CustDefaultDimension.SetRange("No.", "Bill-to Customer No.");
        if CustDefaultDimension.FindSet() then
            repeat
                ContratoDefaultDimension.Init();
                ContratoDefaultDimension.TransferFields(CustDefaultDimension);
                ContratoDefaultDimension."Table ID" := DATABASE::Contrato;
                ContratoDefaultDimension."No." := "No.";
                ContratoDefaultDimension.Insert();
                DimMgt.DefaultDimOnInsert(ContratoDefaultDimension);
            until CustDefaultDimension.Next() = 0;

        OnCopyDefaultDimensionsFromCustomerOnBeforeUpdateDefaultDim(Rec, CurrFieldNo);
        DimMgt.UpdateDefaultDim(DATABASE::Contrato, "No.", "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    procedure PercentCompleted() Result: Decimal
    var
        ContratoCalcStatistics: Codeunit "Contrato Calculate Statistics";
        CL: array[16] of Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePercentCompleted(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        ContratoCalcStatistics.ContratoCalculateCommonFilters(Rec);
        ContratoCalcStatistics.CalculateAmounts();
        ContratoCalcStatistics.GetLCYCostAmounts(CL);
        if CL[4] <> 0 then
            exit((CL[8] / CL[4]) * 100);
        exit(0);
    end;

    procedure PercentInvoiced() Result: Decimal
    var
        ContratoCalcStatistics: Codeunit "Contrato Calculate Statistics";
        PL: array[16] of Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePercentInvoiced(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        ContratoCalcStatistics.ContratoCalculateCommonFilters(Rec);
        ContratoCalcStatistics.CalculateAmounts();
        ContratoCalcStatistics.GetLCYPriceAmounts(PL);
        if PL[12] <> 0 then
            exit((PL[16] / PL[12]) * 100);
        exit(0);
    end;

    procedure PercentOverdue() Result: Decimal
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        QtyOverdue: Decimal;
        QtyTotal: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePercentOverdue(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        ContratoPlanningLine.SetRange("Job No.", "No.");
        QtyTotal := ContratoPlanningLine.Count();
        if QtyTotal = 0 then
            exit(0);
        ContratoPlanningLine.SetFilter("Planning Date", '<%1', WorkDate());
        ContratoPlanningLine.SetFilter("Remaining Qty.", '>%1', 0);
        QtyOverdue := ContratoPlanningLine.Count();
        exit((QtyOverdue / QtyTotal) * 100);
    end;

    local procedure UpdateContratoNoInReservationEntries()
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.SetFilter("Source Type", '%1|%2', DATABASE::"Contrato Planning Line", DATABASE::"Contrato Journal Line");
        ReservEntry.SetRange("Source ID", xRec."No.");
        ReservEntry.ModifyAll("Source ID", "No.", true);
    end;

    procedure CheckReservationEntries(): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        ReservationToDeleteExists: Boolean;
    begin
        ReservationToDeleteExists := false;

        if Status <> Status::Open then begin
            ReservationEntry.SetRange("Source Type", DATABASE::"Contrato Planning Line");
            ReservationEntry.SetRange("Source ID", "No.");
            ReservationToDeleteExists := not ReservationEntry.IsEmpty();
            if ReservationToDeleteExists then
                if not ConfirmManagement.GetResponseOrDefault(ReservEntriesItemTrackLinesDeleteQst, false) then
                    Error(ReservEntriesItemTrackLinesExistErr, Status);
        end;

        exit(ReservationToDeleteExists);
    end;

    procedure PerformAutoReserve(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoPlanningLineReserve: Codeunit "Job Planning Line-Reserve";
        ReservationManagement: Codeunit "Reservation Management";
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
        FullAutoReservation: Boolean;
        AutoReservePossible: Boolean;
    begin
        ContratoPlanningLine.SetRange(Status, ContratoPlanningLine.Status::Order);
        ContratoPlanningLine.SetRange(Reserve, ContratoPlanningLine.Reserve::Always);
        ContratoPlanningLine.SetFilter("Remaining Qty. (Base)", '<>%1', 0);
        AutoReservePossible := ContratoPlanningLine.FindSet();
        if AutoReservePossible then begin
            repeat
                //ContratoPlanningLineReserve.ReservQuantity(ContratoPlanningLine, QtyToReserve, QtyToReserveBase);
                ReservationManagement.SetReservSource(ContratoPlanningLine);
                ReservationManagement.AutoReserve(FullAutoReservation, '', ContratoPlanningLine."Planning Date", QtyToReserve, QtyToReserveBase);
                AutoReservePossible := AutoReservePossible and FullAutoReservation;
                ContratoPlanningLine.UpdatePlanned();
            until ContratoPlanningLine.Next() = 0;
            if not AutoReservePossible then
                Message(AutoReserveNotPossibleMsg);
        end;
    end;

    local procedure UpdateContratoTaskDimension(FieldNumber: Integer; ShortcutDimCode: Code[20])
    var
        ContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateContratoTaskDimension(Rec, FieldNumber, ShortcutDimCode, IsHandled);
        if IsHandled then
            exit;

        if GuiAllowed() and (not GetHideValidationDialog()) then
            if not Confirm(UpdateContratoTaskDimQst, false) then
                exit;

        ContratoTask.SetRange("Job No.", "No.");
        if ContratoTask.FindSet(true) then
            repeat
                case FieldNumber of
                    1:
                        ContratoTask.Validate("Global Dimension 1 Code", ShortcutDimCode);
                    2:
                        ContratoTask.Validate("Global Dimension 2 Code", ShortcutDimCode);
                end;
                ContratoTask.Modify();
            until ContratoTask.Next() = 0;
    end;

    procedure UpdateOverBudgetValue(ContratoNo: Code[20]; Usage: Boolean; Cost: Decimal)
    var
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        ContratoPlanningLine: Record "Contrato Planning Line";
        UsageCost: Decimal;
        ScheduleCost: Decimal;
        NewOverBudget: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateOverBudgetValue(Rec, ContratoNo, Usage, Cost, IsHandled);
        if IsHandled then
            exit;

        if "No." <> ContratoNo then
            if not Get(ContratoNo) then
                exit;

        ContratoLedgerEntry.SetRange("Job No.", ContratoNo);
        ContratoLedgerEntry.CalcSums("Total Cost (LCY)");
        if ContratoLedgerEntry."Total Cost (LCY)" = 0 then
            exit;

        UsageCost := ContratoLedgerEntry."Total Cost (LCY)";

        ContratoPlanningLine.SetRange("Job No.", ContratoNo);
        ContratoPlanningLine.SetRange("Schedule Line", true);
        ContratoPlanningLine.CalcSums("Total Cost (LCY)");
        ScheduleCost := ContratoPlanningLine."Total Cost (LCY)";

        if Usage then
            UsageCost += Cost
        else
            ScheduleCost += Cost;
        NewOverBudget := UsageCost > ScheduleCost;
        if NewOverBudget <> "Over Budget" then begin
            "Over Budget" := NewOverBudget;
            Modify();
        end;
    end;

#if not CLEAN23
    [Obsolete('This method always returns true. Remove this method.', '23.0')]
    procedure IsContratoSimplificationAvailable(): Boolean
    begin
        exit(true);
    end;
#endif

    local procedure AddToMyContratos(ProjectManager: Code[50])
    var
        MyContrato: Record "My Job";
    begin
        if Status <> Status::Open then
            exit;

        if MyContrato.Get(ProjectManager, "No.") then begin
            MyContrato.Description := Description;
            MyContrato."Bill-to Name" := "Bill-to Name";
            MyContrato."Percent Completed" := PercentCompleted();
            MyContrato."Percent Invoiced" := PercentInvoiced();
            MyContrato.Modify();
        end else begin
            MyContrato.Init();
            MyContrato."User ID" := ProjectManager;
            MyContrato."Job No." := "No.";
            MyContrato.Description := Description;
            MyContrato.Status := Status;
            MyContrato."Bill-to Name" := "Bill-to Name";
            MyContrato."Percent Completed" := PercentCompleted();
            MyContrato."Percent Invoiced" := PercentInvoiced();
            MyContrato."Exclude from Business Chart" := false;
            MyContrato.Insert();
        end;
    end;

    local procedure RemoveFromMyContratos()
    var
        MyContrato: Record "My Job";
    begin
        MyContrato.SetFilter("Job No.", '=%1', "No.");
        if MyContrato.FindSet() then
            repeat
                MyContrato.Delete();
            until MyContrato.Next() = 0;
    end;

    local procedure DeleteWhsePickRelation()
    var
        WhsePickRequest: Record "Whse. Pick Request";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        WhsePickRequest.SetRange("Document Type", WhsePickRequest."Document Type"::Job);
        WhsePickRequest.SetRange("Document No.", Rec."No.");
        WhsePickRequest.DeleteAll(true);

        ItemTrackingMgt.DeleteWhseItemTrkgLines(DATABASE::Job, 0, Rec."No.", '', 0, 0, '', false);
    end;

    local procedure DeleteRelatedContratoTasks()
    var
        ContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteRelatedContratoTasks(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        ContratoTask.SetCurrentKey("Job No.");
        ContratoTask.SetRange("Job No.", "No.");
        ContratoTask.SuspendDeletionCheck(true);
        ContratoTask.DeleteAll(true);
    end;

    procedure ToPriceSource(var PriceSource: Record "Price Source"; PriceType: Enum "Price Type")
    begin
        PriceSource.Init();
        PriceSource."Price Type" := PriceType;
        PriceSource.Validate("Source Type", PriceSource."Source Type"::Job);
        PriceSource.Validate("Source No.", "No.");
    end;

    procedure SetContratoDiffBuff(var TempContratoDifferenceBuffer: Record "Contrato Difference Buffer" temporary; ContratoNo: Code[20]; ContratoTaskNo: Code[20]; ContratoTaskType: Option Posting,Heading,Total,"Begin-Total","End-Total"; Type: Option Resource,Item,"G/L Account",Text; No: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; WorkTypeCode: Code[10])
    begin
        TempContratoDifferenceBuffer.Init();
        TempContratoDifferenceBuffer."Job No." := ContratoNo;
        TempContratoDifferenceBuffer."Job Task No." := ContratoTaskNo;
        if ContratoTaskType = ContratoTaskType::Posting then begin
            TempContratoDifferenceBuffer.Type := "Contrato Planning Line Type".FromInteger(Type);
            TempContratoDifferenceBuffer."No." := No;
            TempContratoDifferenceBuffer."Location Code" := LocationCode;
            TempContratoDifferenceBuffer."Variant Code" := VariantCode;
            TempContratoDifferenceBuffer."Unit of Measure code" := UnitofMeasureCode;
            TempContratoDifferenceBuffer."Work Type Code" := WorkTypeCode;
        end;
    end;

    [Scope('OnPrem')]
    procedure SendRecords()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
    begin
        DocumentSendingProfile.SendCustomerRecords(
          DummyReportSelections.Usage::JQ.AsInteger(), Rec, ReportDistributionMgt.GetFullDocumentTypeText(Rec),
          "Bill-to Customer No.", "No.", FieldNo("Bill-to Customer No."), FieldNo("No."));
    end;

    procedure SendProfile(var DocumentSendingProfile: Record "Document Sending Profile")
    var
        ReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
    begin
        DocumentSendingProfile.Send(
          ReportSelections.Usage::JQ.AsInteger(), Rec, "No.", "Bill-to Customer No.",
          ReportDistributionMgt.GetFullDocumentTypeText(Rec), FieldNo("Bill-to Customer No."), FieldNo("No."));
    end;

    procedure PrintRecords(ShowRequestForm: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        ReportSelections: Record "Report Selections";
    begin
        DocumentSendingProfile.TrySendToPrinter(
          ReportSelections.Usage::JQ.AsInteger(), Rec, FieldNo("Bill-to Customer No."), ShowRequestForm);
    end;

    procedure EmailRecords(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        ReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
    begin
        DocumentSendingProfile.TrySendToEMail(
          ReportSelections.Usage::JQ.AsInteger(), Rec, FieldNo("No."),
          ReportDistributionMgt.GetFullDocumentTypeText(Rec), FieldNo("Bill-to Customer No."), ShowDialog);
    end;

    procedure RecalculateContratoWIP()
    var
        Job: Record Contrato;
        ConfirmManagement: Codeunit "Confirm Management";
        ContratoCalculateWIP: Report "Job Calculate WIP";
        Confirmed: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeRecalculateContratoWIP(Rec, IsHandled);
        if IsHandled then
            exit;

        Job.Get("No.");
        // if Job."WIP Method" = '' then
        //     exit;

        Job.SetRecFilter();
        Confirmed := ConfirmManagement.GetResponseOrDefault(RunWIPFunctionsQst, true);
        Commit();
        ContratoCalculateWIP.UseRequestPage(not Confirmed);
        ContratoCalculateWIP.SetTableView(Job);
        ContratoCalculateWIP.Run();
    end;

    local procedure GetReportCaption(ReportID: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, ReportID);
        exit(AllObjWithCaption."Object Caption");
    end;

    local procedure CalcEndingDate() EndingDate: Date
    var
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
    begin
        if "Ending Date" = 0D then
            EndingDate := WorkDate()
        else
            EndingDate := "Ending Date";

        ContratoLedgerEntry.SetRange("Job No.", "No.");
        ContratoLedgerEntry.SetCurrentKey("Job No.", "Posting Date");
        if ContratoLedgerEntry.FindLast() then
            if ContratoLedgerEntry."Posting Date" > EndingDate then
                EndingDate := ContratoLedgerEntry."Posting Date";

        if "Ending Date" >= EndingDate then
            EndingDate := "Ending Date";
    end;

    procedure UpdateReferencedIds()
    var
        TimeSheetLine: Record "Time Sheet Line";
        TimeSheetDetail: Record "Time Sheet Detail";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if IsTemporary then
            exit;

        if not GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        TimeSheetLine.SetCurrentKey(Type, "Job No.");
        TimeSheetLine.SetRange(Type, TimeSheetLine.Type::Job);
        TimeSheetLine.SetRange("Job No.", "No.");
        if not TimeSheetLine.IsEmpty() then
            TimeSheetLine.ModifyAll("Job Id", SystemId);

        TimeSheetDetail.SetCurrentKey(Type, "Job No.");
        TimeSheetDetail.SetRange(Type, TimeSheetLine.Type::Job);
        TimeSheetDetail.SetRange("Job No.", "No.");
        if not TimeSheetDetail.IsEmpty() then
            TimeSheetDetail.ModifyAll("Job Id", SystemId);
    end;

    procedure BilltoContactLookup(): Boolean
    var
        ContactNo: Code[20];
    begin
        ContactNo := ContactLookup("Bill-to Customer No.", "Bill-to Contact No.");
        if ContactNo <> '' then
            Validate("Bill-to Contact No.", ContactNo);
        exit(ContactNo <> '');
    end;

    procedure SelltoContactLookup(): Boolean
    var
        ContactNo: Code[20];
    begin
        ContactNo := ContactLookup("Sell-to Customer No.", "Sell-to Contact No.");
        if ContactNo <> '' then
            Validate("Sell-to Contact No.", ContactNo);
        exit(ContactNo <> '');
    end;

    local procedure ContactLookup(CustomerNo: Code[20]; ContactNo: Code[20]): Code[20]
    begin
        if (CustomerNo <> '') and Cont.Get(ContactNo) then
            Cont.SetRange("Company No.", Cont."Company No.")
        else
            if Cust.Get(CustomerNo) then begin
                if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, CustomerNo) then
                    Cont.SetRange("Company No.", ContBusinessRelation."Contact No.");
            end else
                Cont.SetFilter("Company No.", '<>%1', '''');

        if ContactNo <> '' then
            if Cont.Get(ContactNo) then;
        if Page.RunModal(0, Cont) = Action::LookupOK then
            exit(Cont."No.");
        exit('');
    end;

    procedure CalcContratoTaskLinesEditable() IsEditable: Boolean;
    begin
        IsEditable := "Bill-to Customer No." <> '';

        OnAfterCalcContratoTaskLinesEditable(Rec, IsEditable);
    end;

    procedure ShipToAddressEqualsSellToAddress() Result: Boolean
    begin
        Result :=
          ("Sell-to Address" = "Ship-to Address") and
          ("Sell-to Address 2" = "Ship-to Address 2") and
          ("Sell-to City" = "Ship-to City") and
          ("Sell-to County" = "Ship-to County") and
          ("Sell-to Post Code" = "Ship-to Post Code") and
          ("Sell-to Country/Region Code" = "Ship-to Country/Region Code") and
          ("Sell-to Contact" = "Ship-to Contact");

        OnAfterShipToAddressEqualsSellToAddress(Rec, Result);
    end;

    procedure BillToAddressEqualsSellToAddress(): Boolean
    begin
        if ("Sell-to Address" = "Bill-to Address") and
           ("Sell-to Address 2" = "Bill-to Address 2") and
           ("Sell-to City" = "Bill-to City") and
           ("Sell-to County" = "Bill-to County") and
           ("Sell-to Post Code" = "Bill-to Post Code") and
           ("Sell-to Country/Region Code" = "Bill-to Country/Region Code") and
           ("Sell-to Contact No." = "Bill-to Contact No.") and
           ("Sell-to Contact" = "Bill-to Contact")
        then
            exit(true);
        exit(false);
    end;

    procedure SyncShipToWithSellTo()
    begin
        Rec."Ship-to Name" := Rec."Sell-to Customer Name";
        Rec."Ship-to Name 2" := Rec."Sell-to Customer Name 2";
        Rec."Ship-to Address" := Rec."Sell-to Address";
        Rec."Ship-to Address 2" := Rec."Sell-to Address 2";
        Rec."Ship-to City" := Rec."Sell-to City";
        Rec."Ship-to County" := Rec."Sell-to County";
        Rec."Ship-to Post Code" := Rec."Sell-to Post Code";
        Rec."Ship-to Country/Region Code" := Rec."Sell-to Country/Region Code";
        Rec."Ship-to Contact" := Rec."Sell-to Contact";
        Rec."Ship-to Code" := '';

        OnAfterSyncShipToWithSellTo(Rec);
    end;

    procedure ShipToNameEqualsSellToName(): Boolean
    begin
        exit(
            (Rec."Ship-to Name" = Rec."Sell-to Customer Name") and
            (Rec."Ship-to Name 2" = Rec."Sell-to Customer Name 2")
        );
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    procedure SellToCustomerNoUpdated(var Job: Record Contrato; var xContrato: Record Contrato)
    var
        SellToCustomer: Record Customer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSellToCustomerNoUpdated(Job, xContrato, CurrFieldNo, IsHandled, SkipSellToContact);
        if IsHandled then
            exit;
        if Job."Sell-to Customer No." <> '' then begin
            SellToCustomer.Get(Job."Sell-to Customer No.");
            IsHandled := false;
            OnValidateSellToCustomerNoOnBeforeCheckBlockedCustOnDocs(Rec, SellToCustomer, IsHandled);
            if not IsHandled then
                SellToCustomer.CheckBlockedCustOnDocs(SellToCustomer, Enum::"Sales Document Type"::Order, false, false);
        end;

        CheckSellToCustomerAssosEntriesExist(Job, xContrato);

        if (xContrato."Sell-to Customer No." <> '') and (not GetHideValidationDialog()) and GuiAllowed() then
            if not Confirm(ConfirmChangeQst, false, SellToCustomerTxt) then begin
                Job."Sell-to Customer No." := xContrato."Sell-to Customer No.";
                Job."Sell-to Customer Name" := xContrato."Sell-to Customer Name";
                exit;
            end;

        if Job."Sell-to Customer No." <> '' then begin
            SellToCustomer.Get(Job."Sell-to Customer No.");
            Job."Sell-to Customer Name" := SellToCustomer.Name;
            Job."Sell-to Customer Name 2" := SellToCustomer."Name 2";
            Job."Sell-to Phone No." := SellToCustomer."Phone No.";
            Job."Sell-to E-Mail" := SellToCustomer."E-Mail";
            Job."Sell-to Address" := SellToCustomer.Address;
            Job."Sell-to Address 2" := SellToCustomer."Address 2";
            Job."Sell-to City" := SellToCustomer.City;
            Job."Sell-to Post Code" := SellToCustomer."Post Code";
            Job."Sell-to County" := SellToCustomer.County;
            Job."Sell-to Country/Region Code" := SellToCustomer."Country/Region Code";
            Job.Reserve := SellToCustomer.Reserve;
            if not SkipSellToContact then
                UpdateSellToContact(Job."Sell-to Customer No.");
        end else begin
            Job."Sell-to Customer Name" := '';
            Job."Sell-to Customer Name 2" := '';
            Job."Sell-to Phone No." := '';
            Job."Sell-to E-Mail" := '';
            Job."Sell-to Address" := '';
            Job."Sell-to Address 2" := '';
            Job."Sell-to City" := '';
            Job."Sell-to Post Code" := '';
            Job."Sell-to County" := '';
            Job."Sell-to Country/Region Code" := '';
            Job.Reserve := Job.Reserve::Never;
            Job."Sell-to Contact" := '';
            Job."Sell-to Contact No." := '';
        end;
        OnSellToCustomerNoUpdatedOnAfterTransferFieldsFromCust(Job, xContrato, SellToCustomer);

        if SellToCustomer."Bill-to Customer No." <> '' then
            Job.Validate("Bill-to Customer No.", SellToCustomer."Bill-to Customer No.")
        else
            Job.Validate("Bill-to Customer No.", Rec."Sell-to Customer No.");

        if
            (xContrato.ShipToNameEqualsSellToName() and xContrato.ShipToAddressEqualsSellToAddress()) or
            ((xContrato."Ship-to Code" <> '') and (xContrato."Sell-to Customer No." <> Job."Sell-to Customer No."))
        then
            Job.SyncShipToWithSellTo();

        OnAfterSellToCustomerNoUpdated(Job, xContrato, SellToCustomer);
    end;

    local procedure CheckSellToCustomerAssosEntriesExist(var Job: Record Contrato; var xContrato: Record Contrato)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSellToCustomerAssosEntriesExist(Job, xContrato, IsHandled);
        if not IsHandled then
            if (Job."Sell-to Customer No." = '') or (Job."Sell-to Customer No." <> xContrato."Sell-to Customer No.") then
                if Job.SalesContratoLedgEntryExist() then
                    ThrowAssociatedEntriesExistError(Job, xContrato, Job.FieldNo("Sell-to Customer No."), Job.FieldCaption("Sell-to Customer No."));
    end;

    local procedure BillToCustomerNoUpdated(var Job: Record Contrato; var xContrato: Record Contrato)
    var
        BillToCustomer: Record Customer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBillToCustomerNoUpdated(Job, xContrato, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        CheckBillToCustomerAssosEntriesExist(Job, xContrato);

        if (xContrato."Bill-to Customer No." <> '') and (not GetHideValidationDialog()) and GuiAllowed() then
            if not Confirm(ConfirmChangeQst, false, BillToCustomerTxt) then begin
                Job."Bill-to Customer No." := xContrato."Bill-to Customer No.";
                Job."Bill-to Name" := xContrato."Bill-to Name";
                exit;
            end;

        // Set sell-to first if it hasn't been set yet.
        if (Job."Sell-to Customer No." = '') and (Job."Bill-to Customer No." <> '') then
            Validate("Sell-to Customer No.", Job."Bill-to Customer No.");

        if Job."Bill-to Customer No." <> '' then begin
            BillToCustomer.Get(Job."Bill-to Customer No.");
            Job."Bill-to Name" := BillToCustomer.Name;
            Job."Bill-to Name 2" := BillToCustomer."Name 2";
            Job."Bill-to Address" := BillToCustomer.Address;
            Job."Bill-to Address 2" := BillToCustomer."Address 2";
            Job."Bill-to City" := BillToCustomer.City;
            Job."Bill-to Post Code" := BillToCustomer."Post Code";
            Job."Bill-to County" := BillToCustomer.County;
            Job."Bill-to Country/Region Code" := BillToCustomer."Country/Region Code";
            Job."Payment Method Code" := BillToCustomer."Payment Method Code";
            Job."Payment Terms Code" := BillToCustomer."Payment Terms Code";

            IsHandled := false;
            OnUpdateCustOnBeforeAssignIncoiceCurrencyCode(Job, xContrato, BillToCustomer, IsHandled);
            if not IsHandled then
                "Invoice Currency Code" := BillToCustomer."Currency Code";

            IsHandled := false;
            OnBillToCustomerNoUpdatedOnBeforeAssignCurrencyCode(Job, xContrato, BillToCustomer, IsHandled);
            if not IsHandled then
                if "Invoice Currency Code" <> '' then
                    Validate("Currency Code", '');

            Job."Customer Disc. Group" := BillToCustomer."Customer Disc. Group";
            Job."Customer Price Group" := BillToCustomer."Customer Price Group";
            Job."Language Code" := BillToCustomer."Language Code";
            IsHandled := false;
            OnBillToCustomerNoUpdatedOnBeforeUpdateBillToContact(Job, xContrato, BillToCustomer, IsHandled);
            if not IsHandled then
                UpdateBillToContact(Job."Bill-to Customer No.");

            Job.CopyDefaultDimensionsFromCustomer();
        end else begin
            Job."Bill-to Name" := '';
            Job."Bill-to Name 2" := '';
            Job."Bill-to Address" := '';
            Job."Bill-to Address 2" := '';
            Job."Bill-to City" := '';
            Job."Bill-to Post Code" := '';
            Job."Bill-to County" := '';
            Job."Bill-to Country/Region Code" := '';
            Job."Invoice Currency Code" := '';
            Job."Customer Disc. Group" := '';
            Job."Customer Price Group" := '';
            Job."Language Code" := '';
            Job."Bill-to Contact" := '';
            Job."Bill-to Contact No." := '';
            Job."Payment Method Code" := '';
            Job."Payment Terms Code" := '';
        end;

        if (xContrato."Bill-to Customer No." <> '') and (Job."Bill-to Customer No." <> xContrato."Bill-to Customer No.") then
            UpdateCostPricesOnRelatedContratoPlanningLines(Job);

        OnAfterBillToCustomerNoUpdated(Job, xContrato, BillToCustomer, CurrFieldNo);
    end;

    local procedure UpdateCostPricesOnRelatedContratoPlanningLines(var Job: Record Contrato)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmResult: Boolean;
        IsHandled: Boolean;
    begin
        ContratoPlanningLine.SetRange("Job No.", Job."No.");
        ContratoPlanningLine.SetFilter(Type, '<>%1', ContratoPlanningLine.Type::Text);
        ContratoPlanningLine.SetFilter("No.", '<>%1', '');
        if ContratoPlanningLine.IsEmpty() then
            exit;

        IsHandled := false;
        OnUpdateCostPricesOnRelatedContratoPlanningLinesOnBeforeConfirmUpdate(Job, ConfirmResult, IsHandled);
        if not IsHandled then begin
            if not Job.GetHideValidationDialog() then
                if not ConfirmResult then
                    ConfirmResult := ConfirmManagement.GetResponseOrDefault(UpdateCostPricesOnRelatedLinesQst, true);
        end;
        if not ConfirmResult then
            exit;

        ContratoPlanningLine.FindSet(true);
        repeat
            ContratoPlanningLine."Line Amount" := 0;
            ContratoPlanningLine.UpdateAllAmounts();
            ContratoPlanningLine.Modify(true);
        until ContratoPlanningLine.Next() = 0;

        OnAfterUpdateCostPricesOnRelatedContratoPlanningLines(Job);
    end;

    local procedure CheckBillToCustomerAssosEntriesExist(var Job: Record Contrato; var xContrato: Record Contrato)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBillToCustomerAssosEntriesExist(Job, xContrato, IsHandled);
        if not IsHandled then
            if (Job."Bill-to Customer No." = '') or (Job."Bill-to Customer No." <> xContrato."Bill-to Customer No.") then begin
                if Job.SalesContratoLedgEntryExist() then
                    ThrowAssociatedEntriesExistError(Job, xContrato, Job.FieldNo("Bill-to Customer No."), Job.FieldCaption("Bill-to Customer No."));
                if Job.SalesLineExist() then
                    ThrowAssociatedEntriesExistError(Job, xContrato, Job.FieldNo("Bill-to Customer No."), Job.FieldCaption("Bill-to Customer No."));
            end;
    end;

    local procedure ThrowAssociatedEntriesExistError(var Job: Record Contrato; xContrato: Record Contrato; CallingFieldNo: Integer; FieldCaption: Text)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeThrowAssociatedEntriesExistError(Job, xContrato, CallingFieldNo, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        Error(AssociatedEntriesExistErr, FieldCaption, TableCaption);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeThrowAssociatedEntriesExistError(var Job: Record Contrato; xContrato: Record Contrato; CallingFieldNo: Integer; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    local procedure ShipToCodeValidate()
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        if (xRec."Ship-to Code" <> Rec."Ship-to Code") and (Rec."Ship-to Code" <> '') then
            if ShipToAddress.Get(Rec."Sell-to Customer No.", Rec."Ship-to Code") then begin
                Rec."Ship-to Name" := ShipToAddress.Name;
                Rec."Ship-to Name 2" := ShipToAddress."Name 2";
                Rec."Ship-to Address" := ShipToAddress.Address;
                Rec."Ship-to Address 2" := ShipToAddress."Address 2";
                Rec."Ship-to City" := ShipToAddress.City;
                Rec."Ship-to County" := ShipToAddress.County;
                Rec."Ship-to Post Code" := ShipToAddress."Post Code";
                Rec."Ship-to Country/Region Code" := ShipToAddress."Country/Region Code";
                Rec."Ship-to Contact" := ShipToAddress.Contact;
            end;

        OnAfterShipToCodeValidate(Rec, ShipToAddress);
    end;

    procedure ShouldSearchForCustomerByName(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit(true);

        if not Customer.Get(CustomerNo) then
            exit(true);

        exit(not Customer."Disable Search by Name");
    end;

    procedure CreateWarehousePick()
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        TestField(Status, Status::Open);
        CalcFields("Completely Picked");
        if "Completely Picked" then
            Error(WhseCompletelyPickedErr);

        ContratoPlanningLine.SetRange("Job No.", "No.");
        ContratoPlanningLine.SetFilter("Line Type", '<>%1', ContratoPlanningLine."Line Type"::Billable);
        ContratoPlanningLine.SetRange(Type, ContratoPlanningLine.Type::Item);
        ContratoPlanningLine.SetFilter("Quantity", '>0');
        ContratoPlanningLine.SetLoadFields(ContratoPlanningLine."Job No.", ContratoPlanningLine."Job Contract Entry No.", ContratoPlanningLine."Line No.");

        if ContratoPlanningLine.FindSet() then begin
            repeat
                ItemTrackingMgt.InitItemTrackingForTempWhseWorksheetLine(Enum::"Warehouse Worksheet Document Type"::Job, ContratoPlanningLine."Job No.", ContratoPlanningLine."Job Contract Entry No.", DATABASE::Job, 0, ContratoPlanningLine."Job No.", ContratoPlanningLine."Job Contract Entry No.", ContratoPlanningLine."Line No.");
            until ContratoPlanningLine.Next() = 0;
            Commit();
            RunCreatePickFromWhseSource()
        end
        else
            Error(WhseNoItemsToPickErr);
    end;

    local procedure RunCreatePickFromWhseSource()
    var
        CreatePickFromWhseSource: Report "Whse.-Source - Create Document";
    begin
        //CreatePickFromWhseSource.SetJob(Rec);
        CreatePickFromWhseSource.SetHideValidationDialog(false);
        CreatePickFromWhseSource.UseRequestPage(true);
        CreatePickFromWhseSource.RunModal();
        CreatePickFromWhseSource.GetResultMessage(Enum::"Warehouse Activity Type"::Pick.AsInteger());
    end;

    local procedure InitDefaultContratoPostingGroup()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitDefaultContratoPostingGroup(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Contrato Posting Group" = '' then
            Validate("Contrato Posting Group", ContratosSetup."Default Contrato Posting Group");
    end;

    internal procedure GetQtyReservedFromStockState() Result: Enum "Reservation From Stock"
    var
        ContratoPlanningLineLocal: Record "Contrato Planning Line";
        ContratoPlanningLineReserve: Codeunit "Contrato Planning Line-Reserve";
        QtyReservedFromStock: Decimal;
    begin
        QtyReservedFromStock := ContratoPlanningLineReserve.GetReservedQtyFromInventory(Rec);

        ContratoPlanningLineLocal.SetRange("Job No.", Rec."No.");
        ContratoPlanningLineLocal.SetRange(Type, ContratoPlanningLineLocal.Type::Item);
        ContratoPlanningLineLocal.CalcSums("Remaining Qty. (Base)");

        case QtyReservedFromStock of
            0:
                exit(Result::None);
            ContratoPlanningLineLocal."Remaining Qty. (Base)":
                exit(Result::Full);
            else
                exit(Result::Partial);
        end;
    end;

    local procedure UpdateSellToCust(ContactNo: Code[20])
    var
        Customer: Record Customer;
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactBusinessRelationFound: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateSellToCust(Rec, ContactNo, IsHandled);
        if IsHandled then
            exit;

        if not Contact.Get(ContactNo) then begin
            "Sell-to Contact" := '';
            exit;
        end;
        "Sell-to Contact No." := Contact."No.";

        if Contact.Type = Contact.Type::Person then
            ContactBusinessRelationFound := ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Customer, Contact."No.");
        if not ContactBusinessRelationFound then
            ContactBusinessRelationFound := ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Customer, Contact."Company No.");

        if not ContactBusinessRelationFound then
            ShowSellToContactBusinessRelationNotFoundError(Contact);

        CheckCustomerContactRelation(Contact, "Sell-to Customer No.", ContactBusinessRelation."No.");

        if "Sell-to Customer No." = '' then begin
            SkipSellToContact := true;
            Validate("Sell-to Customer No.", ContactBusinessRelation."No.");
            SkipSellToContact := false;
        end;

        UpdateSellToEmail(Contact);
        Validate("Sell-to Phone No.", Contact."Phone No.");

        UpdateSellToCustomerContact(Customer, Contact);

        if ("Sell-to Customer No." = "Bill-to Customer No.") or ("Bill-to Customer No." = '')
        then
            Validate("Bill-to Contact No.", "Sell-to Contact No.");
    end;

    local procedure CheckCustomerContactRelation(Contact: Record Contact; CustomerNo: Code[20]; ContBusinessRelationNo: Code[20])
    begin
        if (CustomerNo <> '') and (CustomerNo <> ContBusinessRelationNo) then
            Error(ContactBusRelErr, Contact."No.", Contact.Name, CustomerNo);
    end;

    local procedure ShowSellToContactBusinessRelationNotFoundError(Contact: Record Contact)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowSellToContactBusinessRelationNotFoundError(Rec, Contact, IsHandled);
        if IsHandled then
            exit;

        Error(ContactBusRelMissingErr, Contact."No.", Contact.Name);
    end;

    local procedure UpdateSellToEmail(Contact: Record Contact)
    begin
        if (Contact."E-Mail" = '') and ("Sell-to E-Mail" <> '') and GuiAllowed and (not GetHideValidationDialog()) then begin
            if Confirm(ConfirmEmptyEmailQst, false, Contact."No.", "Sell-to E-Mail") then
                Validate("Sell-to E-Mail", Contact."E-Mail");
        end else
            Validate("Sell-to E-Mail", Contact."E-Mail");
    end;

    local procedure UpdateSellToCustomerContact(Customer: Record Customer; Contact: Record Contact)
    begin
        if not SkipSellToContact then
            if (Contact.Type = Contact.Type::Company) and Customer.Get("Sell-to Customer No.") then
                "Sell-to Contact" := Customer.Contact
            else
                if Contact.Type = Contact.Type::Company then
                    "Sell-to Contact" := ''
                else
                    "Sell-to Contact" := Contact.Name;
    end;

    local procedure UpdateShipToContact()
    begin
        if not (CurrFieldNo in [FieldNo("Sell-to Contact"), FieldNo("Sell-to Contact No.")]) then
            exit;

        Validate("Ship-to Contact", "Sell-to Contact");
    end;

    local procedure RefreshModifiedRec()
    begin
        Rec.Find('=');
    end;

    local procedure SetDefaultBin()
    begin
        "Bin Code" := '';

        if "Location Code" = '' then
            exit;

        GetLocation("Location Code");
        if not Location."Bin Mandatory" or Location."Directed Put-away and Pick" then
            exit;

        if Location."To-Job Bin Code" <> '' then
            "Bin Code" := Location."To-Job Bin Code";
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure MessageIfContratoTaskExist(ChangedFieldName: Text[100])
    var
        MessageText: Text;
    begin
        if ContratoTaskExist() and not GetHideValidationDialog() then begin
            MessageText := StrSubstNo(TasksNotUpdatedMsg, ChangedFieldName);
            MessageText := StrSubstNo(SplitMessageTxt, MessageText, UpdateTasksManuallyMsg);
            Message(MessageText);
        end;
    end;

    procedure ContratoTaskExist(): Boolean
    var
        ContratoTask: Record "Contrato Task";
    begin
        ContratoTask.SetRange("Job No.", "No.");
        exit(not ContratoTask.IsEmpty());
    end;

    local procedure InitCustomerOnContratoTasks()
    var
        ContratoTask: Record "Contrato Task";
    begin
        if "Sell-to Customer No." = '' then
            exit;

        ContratoTask.SetRange("Job No.", "No.");
        ContratoTask.SetRange("Job Task Type", ContratoTask."Job Task Type"::Posting);
        ContratoTask.SetFilter("Sell-to Customer No.", '%1', '');
        if ContratoTask.FindSet(true) then
            repeat
                ContratoTask.Validate("Sell-to Customer No.", "Sell-to Customer No.");
                if "Bill-to Customer No." <> "Sell-to Customer No." then begin
                    ContratoTask.SetHideValidationDialog(true);
                    ContratoTask.Validate("Bill-to Customer No.", "Bill-to Customer No.");
                end;
                ContratoTask.Modify(true);
            until ContratoTask.Next() = 0;
    end;

    local procedure ClearInvCurrencyCodeOnContratoTasks()
    var
        ContratoTask: Record "Contrato Task";
    begin
        ContratoTask.SetLoadFields("Invoice Currency Code");
        ContratoTask.SetRange("Job No.", "No.");
        ContratoTask.SetFilter("Invoice Currency Code", '<>%1', '');
        if ContratoTask.IsEmpty() then
            exit;

        ContratoTask.ModifyAll("Invoice Currency Code", '');
    end;

    local procedure ConfirmDeletion()
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        Confirmed: Boolean;
    begin
        ContratoPlanningLine.SetRange("Job No.", "No.");
        if ContratoPlanningLine.FindSet() then
            repeat
                if ContratoPlanningLine."Qty. Posted" < ContratoPlanningLine."Qty. Picked" then begin
                    if not Confirm(ConfirmDeleteQst) then
                        Error('');
                    Confirmed := true;
                end;
            until (ContratoPlanningLine.Next() = 0) or Confirmed;
    end;

    local procedure CheckIfTimeSheetLineLinkExist()
    var
        TimeSheetLine: Record "Time Sheet Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckIfTimeSheetLineLinkExist(Rec, IsHandled);
        if IsHandled then
            exit;

        //TimeSheetLine.CheckIfTimeSheetLineLinkExist(Rec);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCalcRecognizedProfitAmount(var Result: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcContratoTaskLinesEditable(var Job: Record Contrato; var IsEditable: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBillToCustomerNoUpdated(var Job: Record Contrato; var xContrato: Record Contrato; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBillToCustomerNoUpdated(var Job: Record Contrato; xContrato: Record Contrato; BillToCustomer: Record Customer; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoLedgEntryExist(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoPlanningLineExist(var ContratoPlanningLine: Record "Contrato Planning Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnInsert(var Job: Record Contrato; var xContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var Job: Record Contrato; var xContrato: Record Contrato; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterChangeContratoCompletionStatus(var Job: Record Contrato; var xContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShipToCodeValidate(var Job: Record Contrato; ShipToAddress: Record "Ship-to Address")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBillToContact(var Job: Record Contrato; xContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeChangeContratoCompletionStatus(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN24
    [IntegrationEvent(false, false)]
    [Obsolete('Parameter NoSeriesMgt is obsolete and will be removed, update your subscriber accordingly.', '24.0')]
    local procedure OnBeforeAssistEdit(var Job: Record Contrato; var OldContrato: Record Contrato; var Result: Boolean; var IsHandled: Boolean; var NoSeriesManagement: Codeunit NoSeriesManagement)
    begin
    end;
#else
    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var Job: Record Contrato; var OldContrato: Record Contrato; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckContactBillToCustomerBusRelation(var Job: Record Contrato; Contact: Record Contact; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowContactBillToCustomerBusRelationMissingError(var Job: Record Contrato; Contact: Record Contact; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckRemoveFromMyContratosFromModify(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyDefaultDimensionsFromCustomer(var Job: Record Contrato; var IsHandled: Boolean; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePercentCompleted(var Job: Record Contrato; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePercentInvoiced(var Job: Record Contrato; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePercentOverdue(var Job: Record Contrato; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteRelatedContratoTasks(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitContratoNo(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitGlobalDimFromDefalutDim(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitBillToCustomerNo(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecalculateContratoWIP(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestBlocked(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateContratoTaskDimension(var Job: Record Contrato; FieldNumber: Integer; ShortcutDimCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBillToCustomerNo(var Job: Record Contrato; var IsHandled: Boolean; xContrato: Record Contrato; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateCurrencyCode(var Job: Record Contrato; xContrato: Record Contrato; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBillToContactNo(var Job: Record Contrato; xContrato: Record Contrato; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateNo(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var Job: Record Contrato; var xContrato: Record Contrato; FieldNumber: Integer; var ShortcutDimCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateStatus(var Job: Record Contrato; xContrato: Record Contrato; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateOverBudgetValue(var Job: Record Contrato; ContratoNo: Code[20]; Usage: Boolean; Cost: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSellToCustomerNoUpdated(var Job: Record Contrato; var xContrato: Record Contrato; CallingFieldNo: Integer; var IsHandled: Boolean; var SkipSellToContact: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSellToCustomerNoUpdated(var Job: Record Contrato; xContrato: Record Contrato; SellToCustomer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    protected procedure OnSellToCustomerNoUpdatedOnAfterTransferFieldsFromCust(var Job: Record Contrato; xContrato: Record Contrato; SellToCustomer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetQuantityAvailableOnAfterSetFiltersOnContratoLedgerEntry(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; InEntryType: Option; Direction: Option; var ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBillToCustOnAfterAssignBillToContact(var Job: Record Contrato; Contact: Record Contact)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateCustOnBeforeAssignIncoiceCurrencyCode(var Job: Record Contrato; xContrato: Record Contrato; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBillToCity(var Job: Record Contrato; var PostCode: Record "Post Code"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBillToPostCode(var Job: Record Contrato; var PostCode: Record "Post Code"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateSellToCity(var Job: Record Contrato; var PostCode: Record "Post Code"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShipToCity(var Job: Record Contrato; var PostCode: Record "Post Code"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSellToCustomerAssosEntriesExist(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBillToCustomerAssosEntriesExist(var Job: Record Contrato; var xContrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusCompleted(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyDefaultDimensionsFromCustomerOnBeforeUpdateDefaultDim(var Job: Record Contrato; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateSellToCustomerNoOnBeforeCheckBlockedCustOnDocs(var Job: Record Contrato; var Cust: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitDefaultContratoPostingGroup(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateStatusOnBeforeConfirm(var Job: Record "Contrato"; xContrato: Record "Contrato"; var UndidCompleteStatus: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCurrencyUpdatePlanningLines(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBillToCustomerNoUpdatedOnBeforeAssignCurrencyCode(var Job: Record Contrato; xContrato: Record Contrato; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBillToCustomerNoUpdatedOnBeforeUpdateBillToContact(var Job: Record Contrato; xContrato: Record Contrato; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCurrencyUpdatePlanningLinesOnBeforeUpdateContratoPlanningLine(var Job: Record Contrato; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateSellToCustomerName(var Job: Record "Contrato"; var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowSellToContactBusinessRelationNotFoundError(var Job: Record Contrato; Contact: Record Contact; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSyncShipToWithSellTo(var Job: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShipToAddressEqualsSellToAddress(var Job: Record Contrato; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCostPricesOnRelatedContratoPlanningLines(var Job: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSellToCust(var Job: Record Contrato; var ContactNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateCostPricesOnRelatedContratoPlanningLinesOnBeforeConfirmUpdate(var Job: Record Contrato; var ConfirmResult: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckIfTimeSheetLineLinkExist(var Job: Record Contrato; var IsHandled: Boolean)
    begin
    end;
}
