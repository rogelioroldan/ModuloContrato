page 50224 "Contrato Task Card"
{
    Caption = 'Contrato Task Card';
    DataCaptionExpression = Rec.Caption();
    PageType = Card;
    SourceTable = "Contrato Task";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the related contrato task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the contrato task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the contrato planning line.';
                }
                field("Contrato Task Type"; Rec."Contrato Task Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default for the contrato task.';
                    Visible = PerTaskBillingFieldsVisible;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    Importance = Promoted;
                    NotBlank = true;
                    Visible = PerTaskBillingFieldsVisible;
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';

                    trigger OnValidate()
                    begin
                        //Rec.SelltoCustomerNoOnAfterValidate(Rec, xRec);
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupSellToCustomerName(Text));
                    end;
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';
                    Visible = PerTaskBillingFieldsVisible;

                    field("Sell-to Address"; Rec."Sell-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address where the customer is located.';
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the customer on the sales document.';
                    }
                    group(Control60)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; Rec."Sell-to County")
                        {
                            ApplicationArea = All;
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';

                        trigger OnValidate()
                        begin
                            IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Sell-to Country/Region Code");
                        end;
                    }
                    field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the number of the contact person that the sales document will be sent to.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if not Rec.SelltoContactLookup() then
                                exit(false);
                            Text := Rec."Sell-to Contact No.";
                            SellToContact.Get(Rec."Sell-to Contact No.");
                            Rec."Sell-to Contact" := SellToContact.Name;
                            CurrPage.Update();
                            exit(true);
                        end;

                        trigger OnValidate()
                        begin
                            SellToContact.Get(Rec."Sell-to Contact No.");
                            Rec."Sell-to Contact" := SellToContact.Name;
                            CurrPage.Update();
                        end;
                    }
                    field("Sell-to Contact"; Rec."Sell-to Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact';
                        Importance = Additional;
                        Editable = Rec."Sell-to Customer No." <> '';
                        ToolTip = 'Specifies the name of the person to contact at the customer.';
                    }
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an interval or a list of contrato task numbers.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Visible = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Visible = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
                field("New Page"; Rec."New Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether you want a new page to start immediately after this contrato task when you print the contrato tasks. To start a new page after this contrato task, select the New Page check box.';
                }
                field("No. of Blank Lines"; Rec."No. of Blank Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of blank lines that you want inserted before this contrato task in reports that shows contrato tasks.';
                }
            }
            part(ContratoPlanningLines; "Contrato Planning Lines Part")
            {
                ApplicationArea = All;
                SubPageLink = "Contrato No." = field("Contrato No."),
                              "Contrato Task No." = field("Contrato Task No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contrato posting group of the task.';
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the method that is used to calculate the value of work in process for the contrato.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code of the task.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a bin code for specific location of the task.';
                }
            }
            group("Invoice and Shipping")
            {
                Caption = 'Invoice and Shipping';
                Visible = PerTaskBillingFieldsVisible;

                group("Bill-to")
                {
                    Caption = 'Bill-to';
                    field(BillToOptions; BillToOptions)
                    {
                        ApplicationArea = All;
                        Caption = 'Bill-to';
                        ToolTip = 'Specifies the customer that the sales invoice will be sent to. Default (Customer): The same as the customer on the sales invoice. Another Customer: Any customer that you specify in the fields below.';

                        trigger OnValidate()
                        begin
                            if BillToOptions = BillToOptions::"Default (Customer)" then begin
                                Rec.Validate("Bill-to Customer No.", Rec."Sell-to Customer No.");
                                Rec.Validate("Bill-to Contact No.", Rec."Sell-to Contact No.");
                            end;

                            UpdateBillToInformationEditable();
                        end;
                    }
                    group(Control205)
                    {
                        ShowCaption = false;
                        Visible = not (BillToOptions = BillToOptions::"Default (Customer)");

                        field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                        {
                            ApplicationArea = All;
                            Importance = Promoted;
                            ToolTip = 'Specifies the number of the customer who pays for the contrato.';
                            Visible = false;

                            trigger OnValidate()
                            begin
                                CurrPage.Update();
                            end;
                        }
                        field("Bill-to Name"; Rec."Bill-to Name")
                        {
                            Caption = 'Name';
                            ApplicationArea = All;
                            Importance = Promoted;
                            ToolTip = 'Specifies the name of the customer who pays for the contrato.';
                            Editable = ((BillToOptions = BillToOptions::"Another Customer") or ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName));
                            Enabled = ((BillToOptions = BillToOptions::"Another Customer") or ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName));
                            NotBlank = true;

                            trigger OnValidate()
                            begin
                                if not ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName) then begin
                                    if Rec.GetFilter("Bill-to Customer No.") = xRec."Bill-to Customer No." then
                                        if Rec."Bill-to Customer No." <> xRec."Bill-to Customer No." then
                                            Rec.SetRange("Bill-to Customer No.");

                                    CurrPage.Update();
                                end;
                            end;
                        }
                        field("Bill-to Address"; Rec."Bill-to Address")
                        {
                            Caption = 'Address';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the address of the customer to whom you will send the invoice.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to Address 2"; Rec."Bill-to Address 2")
                        {
                            Caption = 'Address 2';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies an additional line of the address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to City"; Rec."Bill-to City")
                        {
                            Caption = 'City';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the city of the address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        group(Control56)
                        {
                            ShowCaption = false;
                            Visible = IsBillToCountyVisible;
                            field("Bill-to County"; Rec."Bill-to County")
                            {
                                ApplicationArea = All;
                                QuickEntry = false;
                                Importance = Additional;
                                ToolTip = 'Specifies the county code of the customer''s billing address.';
                                Caption = 'County';
                                Editable = BillToInformationEditable;
                                Enabled = BillToInformationEditable;
                            }
                        }
                        field("Bill-to Post Code"; Rec."Bill-to Post Code")
                        {
                            Caption = 'Post Code';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code of the customer who pays for the contrato.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                        {
                            Caption = 'Country/Region';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;

                            trigger OnValidate()
                            begin
                                IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
                            end;
                        }
                        field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                        {
                            Caption = 'Contact No.';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the number of the contact person at the customer''s billing address.';
                            Importance = Additional;
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                if not Rec.BilltoContactLookup() then
                                    exit(false);
                                BillToContact.Get(Rec."Bill-to Contact No.");
                                Text := Rec."Bill-to Contact No.";
                                exit(true);
                            end;

                            trigger OnValidate()
                            begin
                                BillToContact.Get(Rec."Bill-to Contact No.");
                            end;
                        }
                        field("Bill-to Contact"; Rec."Bill-to Contact")
                        {
                            Caption = 'Contact';
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the name of the contact person at the customer who pays for the contrato.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                    }
                }
                group("Payment Terms")
                {
                    caption = 'Payment Terms';

                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    }
                    field("Payment Method Code"; Rec."Payment Method Code")
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                        Importance = Additional;
                    }
                }
                group("Ship-to")
                {
                    Caption = 'Ship-to';

                    field(ShippingOptions; ShipToOptions)
                    {
                        ApplicationArea = All;
                        Caption = 'Ship-to';
                        ToolTip = 'Specifies the address that the products on the sales document are shipped to. Default (Sell-to Address): The same as the customer''s sell-to address. Alternate Ship-to Address: One of the customer''s alternate ship-to addresses. Custom Address: Any ship-to address that you specify in the fields below.';

                        trigger OnValidate()
                        var
                            ShipToAddress: Record "Ship-to Address";
                            ShipToAddressList: Page "Ship-to Address List";
                        begin
                            case ShipToOptions of
                                ShipToOptions::"Default (Sell-to Address)":
                                    begin
                                        Rec.Validate("Ship-to Code", '');
                                        Rec.SyncShipToWithSellTo();
                                    end;
                                ShipToOptions::"Alternate Shipping Address":
                                    begin
                                        ShipToAddress.SetRange("Customer No.", Rec."Sell-to Customer No.");
                                        ShipToAddressList.LookupMode := true;
                                        ShipToAddressList.SetTableView(ShipToAddress);

                                        if ShipToAddressList.RunModal() = ACTION::LookupOK then begin
                                            ShipToAddressList.GetRecord(ShipToAddress);
                                            Rec.Validate("Ship-to Code", ShipToAddress.Code);
                                            IsShipToCountyVisible := FormatAddress.UseCounty(ShipToAddress."Country/Region Code");
                                        end else
                                            ShipToOptions := ShipToOptions::"Custom Address";
                                    end;
                                ShipToOptions::"Custom Address":
                                    begin
                                        Rec.Validate("Ship-to Code", '');
                                        IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                                    end;
                            end;
                        end;
                    }
                    group(Control202)
                    {
                        ShowCaption = false;
                        Visible = not (ShipToOptions = ShipToOptions::"Default (Sell-to Address)");
                        field("Ship-to Code"; Rec."Ship-to Code")
                        {
                            ApplicationArea = All;
                            Caption = 'Code';
                            Editable = ShipToOptions = ShipToOptions::"Alternate Shipping Address";
                            Importance = Promoted;
                            ToolTip = 'Specifies the code for another shipment address than the customer''s own address, which is entered by default.';

                            trigger OnValidate()
                            var
                                ShipToAddress: Record "Ship-to Address";
                            begin
                                if (xRec."Ship-to Code" <> '') and (Rec."Ship-to Code" = '') then
                                    Error(EmptyShipToCodeErr);
                                if Rec."Ship-to Code" <> '' then begin
                                    ShipToAddress.Get(Rec."Sell-to Customer No.", Rec."Ship-to Code");
                                    IsShipToCountyVisible := FormatAddress.UseCounty(ShipToAddress."Country/Region Code");
                                end else
                                    IsShipToCountyVisible := false;
                            end;
                        }
                        field("Ship-to Name"; Rec."Ship-to Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Name';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            ToolTip = 'Specifies the name that products on the sales document will be shipped to.';
                        }
                        field("Ship-to Address"; Rec."Ship-to Address")
                        {
                            ApplicationArea = All;
                            Caption = 'Address';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the address that products on the sales document will be shipped to.';
                        }
                        field("Ship-to Address 2"; Rec."Ship-to Address 2")
                        {
                            ApplicationArea = All;
                            Caption = 'Address 2';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies additional address information.';
                        }
                        field("Ship-to City"; Rec."Ship-to City")
                        {
                            ApplicationArea = All;
                            Caption = 'City';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the city of the customer on the sales document.';
                        }
                        group(Control82)
                        {
                            ShowCaption = false;
                            Visible = IsShipToCountyVisible;
                            field("Ship-to County"; Rec."Ship-to County")
                            {
                                ApplicationArea = All;
                                Caption = 'County';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies the state, province or county of the address.';
                            }
                        }
                        field("Ship-to Post Code"; Rec."Ship-to Post Code")
                        {
                            ApplicationArea = All;
                            Caption = 'Post Code';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code.';
                        }
                        field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                        {
                            ApplicationArea = All;
                            Caption = 'Country/Region';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the customer''s country/region.';

                            trigger OnValidate()
                            begin
                                IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                            end;
                        }
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact';
                        ToolTip = 'Specifies the name of the contact person at the address that products on the sales document will be shipped to.';
                    }
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                Visible = PerTaskBillingFieldsVisible;

                field("Invoice Currency Code"; Rec."Invoice Currency Code")
                {
                    ApplicationArea = Suite;
                    Editable = InvoiceCurrencyCodeEditable;
                    ToolTip = 'Specifies the currency code you want to apply when creating invoices for a contrato. By default, the invoice currency code for a contrato is based on what currency code is defined on the customer card.';
                }
                field("Price Calculation Method"; Rec."Price Calculation Method")
                {
                    Visible = ExtendedPriceEnabled;
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the default method of the unit price calculation.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the language to be used on printouts for this contrato.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Contrato Task")
            {
                Caption = '&Contrato Task';
                Image = Task;
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Contrato Task Dimensions";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, contrato, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action(AssemblyOrders)
                {
                    AccessByPermission = TableData "BOM Component" = R;
                    ApplicationArea = Assembly;
                    Caption = 'Assembly Orders';
                    Image = AssemblyOrder;
                    ToolTip = 'View ongoing assembly orders related to the contrato task. ';

                    trigger OnAction()
                    var
                        Contrato: Record Contrato;
                        AssembleToOrderLink: Record "Assemble-to-OrderLinkContrato";
                    begin
                        Contrato.Get(Rec."Contrato No.");
                        //AssembleToOrderLink.ShowAsmOrders(Contrato, Rec."Contrato Task No.");
                    end;
                }
            }
#if not CLEAN25
            group(ActionGroupFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Visible = false;
                ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';

                action(CRMGoToProduct)
                {
                    ApplicationArea = Suite;
                    Caption = 'Contrato Task in Field Service';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service entity.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RecordId);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send updated data to Dynamics 365 Field Service.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.UpdateOneNow(Rec.RecordId);
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Field Service record.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Field Service product.';
                        ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '25.0';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(Rec.RecordId);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Field Service product.';
                        ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '25.0';

                        trigger OnAction()
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(Rec.RecordId);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization Contratos for the resource table.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
#endif
        }
        area(reporting)
        {
            action("Report Contrato Task Quote")
            {
                ApplicationArea = Suite;
                Caption = 'Preview Contrato Task Quote';
                Image = "Report";
                ToolTip = 'Open the Contrato Task Quote report.';
                Visible = PerTaskBillingFieldsVisible;

                trigger OnAction()
                var
                    ContratoTask: Record "Contrato Task";
                    ReportSelection: Record "Report Selections";
                begin
                    ContratoTask.SetCurrentKey("Contrato No.", "Contrato Task No.");
                    ContratoTask.SetFilter("Contrato No.", Rec."Contrato No.");
                    ContratoTask.SetFilter("Contrato Task No.", Rec."Contrato Task No.");
                    ReportSelection.PrintWithDialogForCust(
                        ReportSelection.Usage::"Job Task Quote", ContratoTask, true, Rec.FieldNo("Bill-to Customer No."));
                end;
            }
            action("Send Contrato Task Quote")
            {
                ApplicationArea = Suite;
                Caption = 'Send Contrato Task Quote';
                Image = SendTo;
                ToolTip = 'Send the contrato task quote to the customer. You can change the way that the document is sent in the window that appears.';
                Visible = PerTaskBillingFieldsVisible;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Contrato Tasks-Send", Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Category8)
            {
                Caption = 'Print/Send', Comment = 'Generated from the PromotedActionCategories property index 7.';

                actionref("Report Contrato Task Quote_Promoted"; "Report Contrato Task Quote")
                {
                }
                actionref("Send Contrato Task Quote_Promoted"; "Send Contrato Task Quote")
                {
                }
            }
        }
    }

    var
        SellToContact: Record Contact;
        BillToContact: Record Contact;
        FormatAddress: Codeunit "Format Address";
        BillToInformationEditable: Boolean;
        InvoiceCurrencyCodeEditable: Boolean;
        IsBillToCountyVisible: Boolean;
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        ExtendedPriceEnabled: Boolean;
        EmptyShipToCodeErr: Label 'The Code field can only be empty if you select Custom Address in the Ship-to field.';

    protected var
        ShipToOptions: Enum "Sales Ship-to Options";
        BillToOptions: Enum "Sales Bill-to Options";
        ShouldSearchForCustByName: Boolean;
        PerTaskBillingFieldsVisible: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        if GuiAllowed() then
            SetControlVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        if GuiAllowed() then
            SetControlVisibility();
        UpdateShipToBillToGroupVisibility();
        SellToContact.GetOrClear(Rec."Sell-to Contact No.");
        BillToContact.GetOrClear(Rec."Bill-to Contact No.");
        UpdateBillToInformationEditable();
        UpdateInvoiceCurrencyCodeEditable();
    end;

    trigger OnOpenPage()
    begin
        ActivateFields();
    end;

    local procedure ActivateFields()
    var
        Contrato: Record Contrato;
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
        IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Sell-to Country/Region Code");
        IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");

        if Contrato.Get(Rec."Contrato No.") then
            PerTaskBillingFieldsVisible := Contrato."Task Billing Method" = Contrato."Task Billing Method"::"Multiple customers";

        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    local procedure UpdateShipToBillToGroupVisibility()
    begin
        case true of
            (Rec."Ship-to Code" = '') and Rec.ShipToNameEqualsSellToName() and Rec.ShipToAddressEqualsSellToAddress():
                ShipToOptions := ShipToOptions::"Default (Sell-to Address)";

            (Rec."Ship-to Code" = '') and (not Rec.ShipToNameEqualsSellToName() or not Rec.ShipToAddressEqualsSellToAddress()):
                ShipToOptions := ShipToOptions::"Custom Address";

            Rec."Ship-to Code" <> '':
                ShipToOptions := ShipToOptions::"Alternate Shipping Address";
        end;

        case true of
            (Rec."Bill-to Customer No." = Rec."Sell-to Customer No.") and Rec.BillToAddressEqualsSellToAddress():
                BillToOptions := BillToOptions::"Default (Customer)";

            (Rec."Bill-to Customer No." = Rec."Sell-to Customer No.") and (not Rec.BillToAddressEqualsSellToAddress()):
                BillToOptions := BillToOptions::"Custom Address";

            Rec."Bill-to Customer No." <> Rec."Sell-to Customer No.":
                BillToOptions := BillToOptions::"Another Customer";
        end;
    end;

    local procedure UpdateBillToInformationEditable()
    begin
        BillToInformationEditable :=
            (BillToOptions = BillToOptions::"Custom Address") or
            (Rec."Bill-to Customer No." <> Rec."Sell-to Customer No.");
    end;

    local procedure UpdateInvoiceCurrencyCodeEditable()
    var
        Contrato: Record Contrato;
    begin
        if Contrato.Get(Rec."Contrato No.") then
            InvoiceCurrencyCodeEditable := Contrato."Currency Code" = '';
    end;

    local procedure SetControlVisibility()
    begin
        ShouldSearchForCustByName := Rec.ShouldSearchForCustomerByName(Rec."Sell-to Customer No.");
    end;
}