import { LightningElement, wire } from 'lwc';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    publish
} from "lightning/messageService";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import missionDetailsMessageChannel from "@salesforce/messageChannel/MissionDetailsMessageChannel__c";
import getMissionDetails from '@salesforce/apex/MissionDetailController.getMissionDetails';
import getHeroDetails from '@salesforce/apex/MissionDetailController.getHeroDetails';
import checkHeroMissionAssignments from '@salesforce/apex/MissionDetailController.checkHeroMissionAssignments';
import getAllPossibleRanks from '@salesforce/apex/MissionDetailController.getAllPossibleRanks';
import createMissionAssignment from '@salesforce/apex/MissionDetailController.createMissionAssignment';
import updateMissionAssignment from '@salesforce/apex/MissionDetailController.updateMissionAssignment';

import matchRankError from '@salesforce/label/c.HeroRankDoesNotMatchTheMission';
import tooManyMissionsError from '@salesforce/label/c.TooManyUnfinishedMissions';
import requestToSelectAMissionLabel from '@salesforce/label/c.RequestToSelectAMission';

const acceptLabel = 'Accept';
const completeLabel = 'Complete';
const buttonBrandVariant = 'brand';
const buttonOutlineVariant = 'brand-outline';

export default class MissionDetail extends LightningElement {
    subscription = null;
    superheroMission;
    isLoaded = false;
    buttonLabel;
    buttonVariant;
    showButton = true;
    requestToSelectAMissionLabel = requestToSelectAMissionLabel;

    toastTitle = 'Error';
    errorVariant = 'error';
    errorMode = 'sticky';

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe (
                this.messageContext,
                missionDetailsMessageChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE },
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        getMissionDetails({
            recordId: message.recordId
        })
        .then(result => {
            this.superheroMission = result;
            this.setButtonLabel();
            this.isLoaded = true;
        })
        .catch(error => {
            console.log(error);
        });
    }

    setButtonLabel() {
        if (this.superheroMission.status) {
            if (this.superheroMission.status == 'In Progress') {
                this.buttonLabel = completeLabel;
                this.buttonVariant = buttonOutlineVariant;
                this.showButton = true;
            } else {
                this.buttonLabel = '';
                this.showButton = false;
            }
        } else {
            this.buttonLabel = acceptLabel;
            this.buttonVariant = buttonBrandVariant;
            this.showButton = true;
        }
    }

    handleClick(event) {
        if (event.target.label === acceptLabel) {
            this.handleAccept();
        }

        if (event.target.label === completeLabel) {
            this.handleComplete();
        }
    }

    async handleAccept() {
        var heroDetails, isHeroAvailableForNewMission, isHeroRankMatch;
        try {
            heroDetails = await getHeroDetails();
            isHeroAvailableForNewMission = await checkHeroMissionAssignments();
            isHeroRankMatch = await this.checkHeroRankMatch(heroDetails);
        } catch (error) {
            console.log(error.body.message);
            return;
        }

        if (isHeroRankMatch != null && !isHeroRankMatch) {
            return this.showToast(this.errorVariant, this.toastTitle, matchRankError + ' ' + this.superheroMission.rank, this.errorMode);
        } else if (isHeroAvailableForNewMission!= null && !isHeroAvailableForNewMission) {
            return this.showToast(this.errorVariant, this.toastTitle, tooManyMissionsError, this.errorMode);
        }
        return this.acceptMission(heroDetails);
    }

    handleComplete() {
        this.completeMission();
    }

    async checkHeroRankMatch({rank}) {
        const ranks = await getAllPossibleRanks();
        const index = ranks.findIndex(value => value === this.superheroMission.rank);
        const availableRanks = [ranks[index-1], ranks[index], ranks[index+1]];
        return availableRanks.includes(rank);
    }

    acceptMission(heroDetails) {
        createMissionAssignment({
            heroId: heroDetails.id,
            missionId: this.superheroMission.id
        })
        .then(response => {
            if (response) {
                let message = { recordId: this.superheroMission.id };
                publish(this.messageContext, missionDetailsMessageChannel, message);
            }
        })
        .catch(error => {
            console.log(error.body.message);
        })
    }

    completeMission() {
        updateMissionAssignment({ missionId: this.superheroMission.id })
        .then(response => {
            if (response) {
                let message = { recordId: this.superheroMission.id };
                publish(this.messageContext, missionDetailsMessageChannel, message);
            }
        })
        .catch(error => {
            console.log(error.body.message);
        })
    }
    
    showToast(variant, title, message, mode) {
        const event = new ShowToastEvent({ title, variant, message, mode });
        this.dispatchEvent(event);
    }
}